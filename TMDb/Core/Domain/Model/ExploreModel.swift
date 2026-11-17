import Foundation

enum ExploreMedia: String, Hashable {
    case movie, tv, person

    var label: String {
        switch self {
        case .movie: "Movie"
        case .tv: "TV Show"
        case .person: "Person"
        }
    }
}

enum ExploreCategory: String, CaseIterable, Hashable {
    case all = "All"
    case movies = "Movies"
    case shows = "TV Shows"
    case people = "People"

    var collections: [ExploreCollection] {
        switch self {
        case .all: []
        case .movies: [.nowPlaying, .topRated, .upcoming]
        case .shows: [.airingToday, .onTheAir, .topRated]
        case .people: [.popular, .trending, .alphabetical]
        }
    }

    var sorts: [ExploreSort] {
        self == .people
            ? [.popular, .trending, .name, .knownMovies, .knownShows]
            : [.popular, .newest, .highestRated, .title, .mostVoted]
    }
}

enum ExploreCollection: String, Hashable {
    case nowPlaying = "Now Playing"
    case topRated = "Top Rated"
    case upcoming = "Upcoming"
    case airingToday = "Airing Today"
    case onTheAir = "On The Air"
    case popular = "Popular"
    case trending = "Trending"
    case alphabetical = "A–Z"
}

enum ExploreSort: String, Hashable {
    case popular = "Popular"
    case newest = "Newest"
    case highestRated = "Highest rated"
    case title = "Title A–Z"
    case mostVoted = "Most voted"
    case trending = "Trending"
    case name = "Name A–Z"
    case knownMovies = "Known for Movies"
    case knownShows = "Known for TV"

    func apiValue(for media: ExploreMedia) -> String {
        switch self {
        case .newest: media == .movie ? "primary_release_date.desc" : "first_air_date.desc"
        case .highestRated: "vote_average.desc"
        case .mostVoted: "vote_count.desc"
        case .title: media == .movie ? "title.asc" : "name.asc"
        default: "popularity.desc"
        }
    }

    var includesPeopleInAll: Bool { self == .popular || self == .title }
}

enum ExploreKnownFor: String, CaseIterable {
    case movies = "Movies"
    case shows = "TV Shows"
    case both = "Both"

    func matches(_ media: Set<ExploreMedia>) -> Bool {
        switch self {
        case .movies: media.contains(.movie)
        case .shows: media.contains(.tv)
        case .both: media.contains(.movie) && media.contains(.tv)
        }
    }
}

enum ExploreYearFilter: Equatable {
    case single(Int)
    case range(ClosedRange<Int>)

    var label: String {
        switch self {
        case .single(let year): String(year)
        case .range(let years): "\(years.lowerBound)–\(years.upperBound)"
        }
    }

    var dates: ClosedRange<String> {
        let years: ClosedRange<Int>
        switch self {
        case .single(let year): years = year...year
        case .range(let range): years = range
        }
        return "\(years.lowerBound)-01-01"..."\(years.upperBound)-12-31"
    }
}

struct ExploreFilters: Equatable {
    var genres: Set<String> = []
    var year: ExploreYearFilter?
    var minimumRating: Int?
    var department: String?
    var knownFor: ExploreKnownFor?

    var filtersTitles: Bool { !genres.isEmpty || year != nil || minimumRating != nil }
    var isActive: Bool { filtersTitles || department != nil || knownFor != nil }

    var summary: String {
        (genres.sorted() + [year?.label, minimumRating.map { "\($0).0+" }, department, knownFor?.rawValue]
            .compactMap { $0 }).joined(separator: " · ")
    }
}

struct ExploreItem: Identifiable {
    struct ID: Hashable {
        let media: ExploreMedia
        let value: Int
    }

    let id: ID
    let title: String
    let imagePath: String?
    let date: String?
    let genres: [Int]
    let overview: String?
    let rating: Double?
    let popularity: Double?
    let votes: Int?
    let department: String?
    let knownFor: Set<ExploreMedia>
}

struct ExplorePage {
    let items: [ExploreItem]
    let totalPages: Int
}

struct ExploreQuery {
    let media: ExploreMedia
    let page: Int
    let collection: ExploreCollection?
    let sort: ExploreSort
    let genreIDs: [Int]
    let year: ExploreYearFilter?
    let minimumRating: Int?

    var trendingPeople: Bool {
        media == .person && (sort == .trending || (sort != .popular && collection == .trending))
    }
}
