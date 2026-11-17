struct ExploreResponse: Decodable {
    struct Dates: Decodable {
        let minimum: String
        let maximum: String
    }

    let results: [ExploreResultResponse]
    let totalPages: Int
    let dates: Dates?

    enum CodingKeys: String, CodingKey {
        case results, dates
        case totalPages = "total_pages"
    }
}

struct ExploreResultResponse: Decodable {
    struct KnownWork: Decodable {
        let mediaType: String?
        enum CodingKeys: String, CodingKey {
            case mediaType = "media_type"
        }
    }

    let id: Int
    let title: String?
    let name: String?
    let posterPath: String?
    let profilePath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let genres: [Int]?
    let overview: String?
    let rating: Double?
    let popularity: Double?
    let votes: Int?
    let department: String?
    let knownFor: [KnownWork]?

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview, popularity
        case posterPath = "poster_path"
        case profilePath = "profile_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case genres = "genre_ids"
        case rating = "vote_average"
        case votes = "vote_count"
        case department = "known_for_department"
        case knownFor = "known_for"
    }
}
