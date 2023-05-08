//
//  DetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import Combine

class DetailPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = DetailRouter()
    
    private let detailUseCase: DetailUseCase
    private let favoriteUseCase: FavoriteUseCase
    
    @Published var movie = MovieDetailModel(
        id: 436270,
        title: "Black Adam",
        rating: 7.1,
        posterPath: "/bQXAqRx2Fgc46uCVWgoPz5L5Dtr.jpg",
        overview: "Nearly 5,000 years after he was bestowed with the almighty powers of the Egyptian gods—and imprisoned just as quickly—Black Adam is freed from his earthly tomb, ready to unleash his unique form of justice on the modern world.",
        tagline: "The world needed a hero. It got Black Adam.",
        releaseDate: "2022-10-19",
        backdropPath: "/3CxUndGhUcZdt1Zggjdb2HkLLQX.jpg",
        runtime: 125,
        certification: "NR",
        genre: "Action",
        cast: []
    )
    @Published var errorMessage = ""
    @Published var loadingState = false
    @Published var isFavorite = false
    
    init(detailUseCase: DetailUseCase, favoriteUseCase: FavoriteUseCase) {
        self.detailUseCase = detailUseCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    func getMovie() {
        self.loadingState = true
        detailUseCase.getMovie()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { movie in
                self.movie = movie
                self.findFavorite(movieId: movie.id)
            }.store(in: &cancellable)
    }
    
    func addFavorite(movie: MovieDetailModel) {
        favoriteUseCase.addFavorite(movie: movie)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                        self.isFavorite = false
                    case .finished:
                        self.isFavorite = true
                }
            } receiveValue: {
                self.isFavorite = $0
            }.store(in: &cancellable)
    }
    
    func deleteFavorite(movieId: Int) {
        favoriteUseCase.deleteFavorite(movieId: movieId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case.finished:
                        self.isFavorite = false
                }
            } receiveValue: {
                self.isFavorite = !$0
            }.store(in: &cancellable)
    }
    
    private func findFavorite(movieId: Int) {
        self.loadingState = true
        favoriteUseCase.getFavorites()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case.finished:
                        self.loadingState = false
                }
            } receiveValue: { favorites in
                if favorites.first(where: { movie in movie.id == movieId }) != nil {
                    self.isFavorite = true
                } else {
                    self.isFavorite = false
                }
            }.store(in: &cancellable)
    }
    
    func linkBuilder<Content: View>(
        for personId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makePersonDetailView(for: personId)) {
            content()
        }
        .buttonStyle(.plain)
    }
}
