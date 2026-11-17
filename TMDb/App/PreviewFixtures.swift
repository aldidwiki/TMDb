#if DEBUG
import Combine
import Foundation
import SwiftData
import UIKit

enum PreviewFixtures {
    static let movie = MovieModel(id: 1, title: "The Last Horizon", posterPath: "", rating: 8.4,
                                  releaseDate: "2025-04-18", genreIDs: [878], overview: "A crew follows a signal beyond the solar system.")
    static let movies = [
        movie,
        MovieModel(id: 2, title: "After the Rain", posterPath: "", rating: 7.8, releaseDate: "2024-09-21"),
        MovieModel(id: 3, title: "Northern Lights", posterPath: "", rating: 7.2, releaseDate: "2023-11-03")
    ]
    static let genre = GenreModel(id: 878, name: "Science Fiction")
    static let genreTile = DashboardPresenter.GenreTile(id: 878, name: "Science Fiction", monogram: "SF",
                                                        background: 0xEEF0FF, accent: 0x3B4CCA)
    static let movieDetail = MovieDetailModel(
        id: 1, title: "The Last Horizon", rating: 8.4, posterPath: "", overview: movie.overview,
        tagline: "Beyond the signal", releaseDate: movie.releaseDate, backdropPath: "", runtime: 118,
        certification: "PG-13", genre: genre.name, cast: [], budget: 0, revenue: 0, status: "Released",
        spokenLanguage: "English", instagramId: "", facebookId: "", twitterId: "", imdbId: "",
        videos: [], voteCount: 120, director: "Alex Morgan", usReleaseDate: movie.releaseDate, composer: nil
    )
    static let show = TvShowDetailModel(
        id: 2, backdropPath: "", releaseDate: "2024-09-21", title: "After the Rain", overview: "Two friends return to their hometown.",
        posterPath: "", tagline: "", status: "Returning Series", type: "Scripted", genre: "Drama", rating: 7.8,
        runtime: 42, spokenLanguage: "English", contentRating: "TV-14", instagramId: "", facebookId: "",
        twitterId: "", imdbId: "", videos: [video], credits: [credit], networks: [], seasons: [season], voteCount: 42,
        creators: "Sam Lee", executiveProducers: nil
    )
    static let person = PersonModel(id: 3, name: "Alex Morgan", profilePath: "", birthday: "1986-05-14",
                                    deathday: "", gender: "", biography: "Alex Morgan is a filmmaker and actor.",
                                    birthplace: "London", knownFor: "Acting", alsoKnownAs: [], credits: [],
                                    instagramId: "", facebookId: "", imdbId: "", twitterId: "")
    static let search = SearchModel(id: .init(mediaType: .movie, value: 1), name: movie.title,
                                    releaseDate: movie.releaseDate, imagePath: "", voteAverage: movie.rating,
                                    overview: movie.overview, knownForDepartment: "")
    static let personSearch = SearchModel(id: .init(mediaType: .person, value: 3), name: person.name,
                                          releaseDate: "", imagePath: "", voteAverage: nil, overview: "",
                                          knownForDepartment: "Acting")
    static let favorite = FavoriteModel(id: .init(mediaType: .movie, mediaID: 1), title: movie.title,
                                        posterPath: "", rating: movie.rating, releaseDate: movie.releaseDate,
                                        overview: movie.overview, voteCount: 120)
    static let favoritePerson = FavoriteModel(id: .init(mediaType: .person, mediaID: 3), title: person.name,
                                              posterPath: "", department: "Acting")
    static let explore = ExploreItem(id: .init(media: .movie, value: 1), title: movie.title, imagePath: nil,
                                     date: movie.releaseDate, genres: [878], overview: movie.overview,
                                     rating: movie.rating, popularity: 8.4, votes: 120, department: nil,
                                     knownFor: [])

    static let credit = CreditModel(id: person.id, name: person.name, profilePath: "", characterName: "Captain Vega",
                                     order: 0, popularity: 12, releaseDate: "", episodeCount: 4, mediaType: "movie")
    static let creditItem = PersonPresenter.CreditListItem(id: .movie(movie.id), title: movie.title, releaseYear: "2025",
                                                           posterPath: "", roles: [credit.characterName], episodeCount: 0)
    static let similarTitle = SimilarTitle(id: 2, title: "After the Rain", posterPath: "", releaseDate: "2024-09-21", rating: 7.8)
    static let season = TvShowSeasonModel(id: 10, posterPath: "", seasonName: "Season 1", seasonAirDate: "2024-09-21",
                                          episodeCount: 4, seasonNumber: 1, seasonOverview: "Two friends return to their hometown.", seasonVoteAverage: 7.8)
    static let episode = TvShowSeasonDetailModel(id: 100, name: "The Return", overview: show.overview, runtime: 42,
                                                 rating: 7.8, episodeNumber: 1, stillPath: "", airDate: show.releaseDate)
    static let video = VideoModel(id: "preview", key: "example", name: "Official Trailer", site: "YouTube", type: "Trailer")
    static let backdrop = ImageModel(id: 1, filePath: "", aspectRatio: 16.0 / 9)
    static let portrait = PersonImageModel(filePath: "", aspectRatio: 9.0 / 16)

    static let thumbnail = UIImage(systemName: "photo")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)

    @MainActor
    static func searchPresenter() -> SearchPresenter {
        let presenter = SearchPresenter(searchUseCase: UseCases())
        presenter.searchQuery = "Horizon"
        return presenter
    }

    @MainActor
    static func contentView() -> ContentView {
        let useCases = UseCases()
        return ContentView(dashboardUseCase: useCases, detailUseCase: useCases, exploreUseCase: useCases,
                           searchUseCase: useCases, favoriteUseCase: favorites())
    }

    @MainActor
    static func favorites() -> FavoriteUseCase {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: FavoriteEntity.self, configurations: config)
            let interactor = FavoriteInteractor(favoriteRepository: FavoriteRepository(contextProvider: { container.mainContext }))
            _ = try interactor.toggleFavorite(favorite)
            _ = try interactor.toggleFavorite(favoritePerson)
            return interactor
        } catch {
            preconditionFailure("Could not prepare Favorites preview: \(error)")
        }
    }

    struct UseCases: DashboardUseCase, DetailUseCase, GenreUseCase, ExploreUseCase, SearchUseCase, PersonUseCase, TvShowUseCase {
        func getTrendingMovies() -> AnyPublisher<[MovieModel], Error> { value(PreviewFixtures.movies) }
        func getNowPlayingMovies() -> AnyPublisher<[MovieModel], Error> { value(PreviewFixtures.movies) }
        func getMovieGenres() -> AnyPublisher<[GenreModel], Error> { value([PreviewFixtures.genre]) }
        func getMovie(movieId: Int) -> AnyPublisher<MovieDetailModel, Error> { value(PreviewFixtures.movieDetail) }
        func getSimilarMovies(movieId: Int, page: Int) -> AnyPublisher<SimilarTitlesPage, Error> { similar(page) }
        func getMovieBackdrops(movieId: Int) -> AnyPublisher<[ImageModel], Error> { value([PreviewFixtures.backdrop]) }
        func discoverMovies(query: GenreMovieQuery) -> AnyPublisher<GenreMoviePage, Error> {
            value(.init(movies: PreviewFixtures.movies, totalPages: 1, totalResults: PreviewFixtures.movies.count))
        }
        func page(_ query: ExploreQuery) -> AnyPublisher<ExplorePage, Error> {
            value(.init(items: query.media == .movie ? [PreviewFixtures.explore] : [], totalPages: 1))
        }
        func genres(for media: ExploreMedia) -> AnyPublisher<[GenreModel], Error> { value([PreviewFixtures.genre]) }
        func search(query: String, page: Int) -> AnyPublisher<SearchPage, Error> {
            value(.init(results: [PreviewFixtures.search, PreviewFixtures.personSearch], totalPages: 1))
        }
        func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error> { value(PreviewFixtures.person) }
        func getPersonImage(personId: Int) -> AnyPublisher<[PersonImageModel], Error> { value([PreviewFixtures.portrait]) }
        func getTvShow(tvShowId: Int) -> AnyPublisher<TvShowDetailModel, Error> { value(PreviewFixtures.show) }
        func getSimilarTvShows(tvShowId: Int, page: Int) -> AnyPublisher<SimilarTitlesPage, Error> { similar(page) }
        func getTvShowSeasonDetail(tvShowId: Int, seasonNumber: Int) -> AnyPublisher<[TvShowSeasonDetailModel], Error> { value([PreviewFixtures.episode]) }
        func getTvShowBackdrop(tvId: Int) -> AnyPublisher<[ImageModel], Error> { value([]) }

        private func similar(_ page: Int) -> AnyPublisher<SimilarTitlesPage, Error> {
            value(.init(titles: [PreviewFixtures.similarTitle], page: page, totalPages: 1, totalResults: 1))
        }

        private func value<T>(_ value: T) -> AnyPublisher<T, Error> {
            Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
}
#endif
