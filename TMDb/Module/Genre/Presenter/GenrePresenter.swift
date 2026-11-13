import Foundation
import Observation

struct GenreListingMovie: Identifiable {
    let id: Int
    let title: String
    let year: Int
    let duration: Int
    let rating: Double
    let overview: String
    let posterColor: UInt32
    let popularity: Int
    let votes: Int
}

@MainActor
@Observable
final class GenrePresenter {
    enum Sort: String, CaseIterable {
        case popularity = "Popularity"
        case newest = "Newest first"
        case highestRated = "Highest rated"
        case title = "Title A–Z"
        case mostVoted = "Most voted"
    }

    enum ReleaseYear: String, CaseIterable {
        case year2024 = "2024"
        case year2023 = "2023"
        case year2022 = "2022"
        case year2021 = "2021"
        case all = "All years"

        var value: Int? { Int(rawValue) }
    }

    enum MinimumRating: String, CaseIterable {
        case six = "6.0+"
        case seven = "7.0+"
        case eight = "8.0+"
        case nine = "9.0+"
        case any = "Any rating"

        var value: Double { Double(rawValue.dropLast()) ?? 0 }
    }

    var sort: Sort = .popularity
    var releaseYear: ReleaseYear = .all
    var minimumRating: MinimumRating = .any

    // Sample entries for the listing prototype. Detail links use real TMDb movie IDs.
    private let sampleMovies: [GenreListingMovie] = [
        .init(id: 693134, title: "Dune: Part Two", year: 2024, duration: 166, rating: 8.8,
              overview: "A mythic journey across Arrakis.", posterColor: 0x292667, popularity: 6, votes: 142000),
        .init(id: 670292, title: "The Creator", year: 2023, duration: 133, rating: 7.8,
              overview: "Humanity faces a new intelligence.", posterColor: 0x173D49, popularity: 5, votes: 98000),
        .init(id: 335984, title: "Blade Runner 2049", year: 2017, duration: 164, rating: 8.0,
              overview: "A discovery changes everything.", posterColor: 0x3F3D67, popularity: 4, votes: 120000),
        .init(id: 157336, title: "Interstellar", year: 2014, duration: 169, rating: 8.6,
              overview: "A voyage beyond the stars.", posterColor: 0x2B5963, popularity: 3, votes: 180000),
        .init(id: 545611, title: "Everything Everywhere All at Once", year: 2022, duration: 139, rating: 7.8,
              overview: "An extraordinary journey through many worlds.", posterColor: 0x4D2848, popularity: 2, votes: 87000),
        .init(id: 414906, title: "The Batman", year: 2022, duration: 176, rating: 7.7,
              overview: "A new mystery unfolds in Gotham.", posterColor: 0x54293C, popularity: 1, votes: 110000)
    ]

    var movies: [GenreListingMovie] {
        let filtered = sampleMovies.filter { movie in
            (releaseYear.value == nil || movie.year == releaseYear.value) && movie.rating >= minimumRating.value
        }
        switch sort {
        case .popularity: return filtered.sorted { $0.popularity > $1.popularity }
        case .newest: return filtered.sorted { $0.year > $1.year }
        case .highestRated: return filtered.sorted { $0.rating > $1.rating }
        case .title: return filtered.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        case .mostVoted: return filtered.sorted { $0.votes > $1.votes }
        }
    }
}
