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
    enum SimilarMoviesState {
        case idle
        case loading
        case loaded([MovieModel])
        case failed
    }

    private var cancellables: Set<AnyCancellable> = []
    private let router = DetailRouter()
    private let detailUseCase: DetailUseCase
    private let favoriteUseCase: FavoriteUseCase

    private(set) var movie: MovieDetailModel?
    private(set) var isLoadingMovie = false
    private(set) var movieFailed = false
    private(set) var similarMovies: SimilarMoviesState = .idle
    private(set) var isFavorite = false
    var showsFavoriteError = false

    init(detailUseCase: DetailUseCase, favoriteUseCase: FavoriteUseCase) {
        self.detailUseCase = detailUseCase
        self.favoriteUseCase = favoriteUseCase
    }

    var topCast: [CreditModel] {
        var seen: Set<Int> = []
        let cast = (movie?.cast ?? []).sorted { $0.order < $1.order }
        return Array(cast.filter {
            $0.id > 0 && !$0.name.isEmpty && seen.insert($0.id).inserted
        }.prefix(10))
    }

    func load(movieId: Int) {
        if movie == nil && !movieFailed { getMovie(movieId: movieId) }
        if case .idle = similarMovies { getSimilarMovies(movieId: movieId) }
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

    func getSimilarMovies(movieId: Int) {
        if case .loading = similarMovies { return }
        similarMovies = .loading

        detailUseCase.getSimilarMovies(movieId: movieId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion { self?.similarMovies = .failed }
            } receiveValue: { [weak self] movies in
                var seen: Set<Int> = [movieId]
                let titles = Array(movies.filter {
                    $0.id > 0 && seen.insert($0.id).inserted
                }.prefix(10))
                self?.similarMovies = .loaded(titles)
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

    func toSimilarMovie<Content: View>(
        for movieId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            router.makeMovieDetailView(for: movieId)
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
