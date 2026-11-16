struct SimilarTitlesPage {
    let titles: [SimilarTitle]
    let page: Int
    let totalPages: Int
    let totalResults: Int?
}

struct SimilarTitle: Identifiable {
    let id: Int
    let title: String
    let posterPath: String
    let releaseDate: String
    let rating: Double?
}
