//
//  DetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Combine
import Observation
import SwiftUI

@MainActor
@Observable
final class MovieDetailPresenter {
    private var cancellables: Set<AnyCancellable> = []
    private let router = DetailRouter()
    private let detailUseCase: DetailUseCase
    private let favoriteUseCase: FavoriteUseCase

    private(set) var movie: MovieDetailModel?
    private(set) var isLoadingMovie = false
    private(set) var movieFailed = false
    let similarTitles: SimilarTitlesPresenter
    private(set) var isFavorite = false
    var showsFavoriteError = false

    init(detailUseCase: DetailUseCase, favoriteUseCase: FavoriteUseCase, movieId: Int) {
        self.detailUseCase = detailUseCase
        self.favoriteUseCase = favoriteUseCase
        similarTitles = SimilarTitlesPresenter(sourceID: movieId) { page in
            detailUseCase.getSimilarMovies(movieId: movieId, page: page)
        }
    }

    var cast: [CreditModel] {
        CreditModel.castInBillingOrder(movie?.cast ?? [])
    }

    func load(movieId: Int) {
        if movie == nil && !movieFailed { getMovie(movieId: movieId) }
        similarTitles.load()
    }

    func getMovie(movieId: Int) {
        guard !isLoadingMovie else { return }
        isLoadingMovie = true
        movieFailed = false

        detailUseCase.getMovie(movieId: movieId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingMovie = false
                if case .failure = completion { self?.movieFailed = true }
            } receiveValue: { [weak self] movie in
                self?.movie = movie
            }
            .store(in: &cancellables)
    }

    func checkFavoriteStatus(movieId: Int) {
        do {
            isFavorite = try favoriteUseCase.isFavorited(.init(mediaType: .movie, mediaID: movieId))
        } catch {
            showsFavoriteError = true
        }
    }

    func toggleFavorite() {
        guard let movie, movie.id > 0 else { return }
        do {
            isFavorite = try favoriteUseCase.toggleFavorite(Mapper.mapMovieToFavorite(movie))
        } catch {
            showsFavoriteError = true
        }
    }

    func toPersonDetail<Content: View>(
        for personId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            router.makePersonDetailView(for: personId)
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }

    func toFullCast<Content: View>(
        title: String,
        cast: [CreditModel],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            router.makeFullCastView(title: title, media: .movie, cast: cast)
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }

    func toMovieImageGallery<Content: View>(
        for movieId: Int,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            router.makeMovieImageGalleryView(movieId: movieId, title: title)
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }
}
