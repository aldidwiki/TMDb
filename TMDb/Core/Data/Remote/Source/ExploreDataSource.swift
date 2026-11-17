import Alamofire
import Combine
import Foundation

final class ExploreDataSource {
    func genres(for media: ExploreMedia) -> AnyPublisher<GenreResponse, Error> {
        request("genre/\(media.rawValue)/list", parameters: ["language": "en-US"])
    }

    func page(_ query: ExploreQuery) -> AnyPublisher<ExploreResponse, Error> {
        if query.media == .person {
            if query.trendingPeople {
                return request("trending/person/week", parameters: ["language": "en-US"])
            }
            return request("person/popular", parameters: ["page": query.page, "language": "en-US"])
        }

        if query.media == .movie, let path = theatricalPath(query.collection) {
            let base: Parameters = ["page": query.page, "region": "ID", "language": "en-US"]
            if query.sort == .popular, query.genreIDs.isEmpty, query.year == nil, query.minimumRating == nil {
                return request(path, parameters: base)
            }

            let schedule: AnyPublisher<ExploreResponse, Error> = request(
                path, parameters: ["page": 1, "region": "ID", "language": "en-US"]
            )
            return schedule.flatMap { response -> AnyPublisher<ExploreResponse, Error> in
                guard let dates = response.dates else {
                    return Fail(error: Foundation.URLError(.cannotParseResponse)).eraseToAnyPublisher()
                }
                return self.discover(query, theatricalDates: dates)
            }
            .eraseToAnyPublisher()
        }
        return discover(query, theatricalDates: nil)
    }

    private func discover(
        _ query: ExploreQuery,
        theatricalDates: ExploreResponse.Dates?
    ) -> AnyPublisher<ExploreResponse, Error> {
        var parameters: Parameters = [
            "language": "en-US",
            "include_adult": false,
            "page": query.page,
            "sort_by": query.sort.apiValue(for: query.media)
        ]
        if !query.genreIDs.isEmpty {
            parameters["with_genres"] = query.genreIDs.map(String.init).joined(separator: "|")
        }
        if let rating = query.minimumRating {
            parameters["vote_average.gte"] = rating
        }
        if query.collection == .topRated {
            parameters["vote_count.gte"] = 200
            if query.media == .movie { parameters["without_genres"] = "99,10755" }
        }
        let yearDates = query.year?.dates
        if query.media == .movie {
            if let dates = theatricalDates {
                parameters["region"] = "ID"
                parameters["with_release_type"] = "2|3"
                let lower = yearDates.map { max(dates.minimum, $0.lowerBound) } ?? dates.minimum
                let upper = yearDates.map { min(dates.maximum, $0.upperBound) } ?? dates.maximum
                guard lower <= upper else {
                    return Just(ExploreResponse(results: [], totalPages: 0, dates: nil))
                        .setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                parameters["release_date.gte"] = lower
                parameters["release_date.lte"] = upper
            } else if case .single(let year) = query.year {
                parameters["primary_release_year"] = year
            } else if let yearDates {
                parameters["primary_release_date.gte"] = yearDates.lowerBound
                parameters["primary_release_date.lte"] = yearDates.upperBound
            }
        } else {
            if case .single(let year) = query.year {
                parameters["first_air_date_year"] = year
            } else if let yearDates {
                parameters["first_air_date.gte"] = yearDates.lowerBound
                parameters["first_air_date.lte"] = yearDates.upperBound
            }
            if query.collection == .airingToday || query.collection == .onTheAir {
                let now = Date()
                let calendar = Calendar.current
                let lastDay = calendar.date(byAdding: .day, value: query.collection == .onTheAir ? 6 : 0, to: now) ?? now
                let format = Date.ISO8601FormatStyle(timeZone: calendar.timeZone).year().month().day()
                parameters["air_date.gte"] = now.formatted(format)
                parameters["air_date.lte"] = lastDay.formatted(format)
                parameters["timezone"] = calendar.timeZone.identifier
            }
        }
        return request("discover/\(query.media.rawValue)", parameters: parameters)
    }

    private func theatricalPath(_ collection: ExploreCollection?) -> String? {
        switch collection {
        case .nowPlaying: "movie/now_playing"
        case .upcoming: "movie/upcoming"
        default: nil
        }
    }

    private func request<Response: Decodable>(
        _ path: String,
        parameters: Parameters
    ) -> AnyPublisher<Response, Error> {
        AF.request(API.baseUrl + path, parameters: parameters, headers: API.headers)
            .validate()
            .publishDecodable(type: Response.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
