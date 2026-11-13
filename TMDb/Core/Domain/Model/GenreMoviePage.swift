struct GenreMoviePage {
    let movies: [MovieModel]
    let totalPages: Int
    let totalResults: Int
}

struct GenreMovieQuery {
    let genreID: Int
    let sortBy: String
    let releaseYear: Int?
    let minimumRating: Double?
    let page: Int
    let region: String
}
