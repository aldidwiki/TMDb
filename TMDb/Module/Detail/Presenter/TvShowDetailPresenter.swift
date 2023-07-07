//
//  TvShowDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Combine
import SwiftUI

class TvShowDetailPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = DetailRouter()
    private let tvShowUseCase: TvShowUseCase
    private let favoriteUseCase: FavoriteUseCase
    
    @Published var errorMessage = ""
    @Published var loadingState = false
    @Published var tvShow = TvShowDetailModel(
        id: 114472,
        backdropPath: "",
        releaseDate: "",
        title: "",
        overview: "",
        posterPath: "",
        tagline: "",
        status: "",
        type: "",
        genre: "",
        rating: 0.0,
        runtime: 0,
        spokenLanguage: "",
        contentRating: "",
        instagramId: "",
        facebookId: "",
        twitterId: "",
        imdbId: "",
        videos: [],
        credits: [],
        networks: []
    )
    @Published var isFavorite = false
    
    init(tvShowUseCase: TvShowUseCase, favoriteUseCase: FavoriteUseCase) {
        self.tvShowUseCase = tvShowUseCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    func getTvShow(tvShowId: Int) {
        self.loadingState = true
        tvShowUseCase.getTvShow(tvShowId: tvShowId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { tvShow in
                self.tvShow = tvShow
                self.findFavorite(tvShowId: tvShow.id)
            }.store(in: &cancellable)
    }
    
    func addFavorite(tvShowDetailModel: TvShowDetailModel) {
        favoriteUseCase.addFavorite(tvShow: tvShowDetailModel)
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
            }
            .store(in: &cancellable)
    }
    
    func deleteFavorite(tvShowId: Int) {
        favoriteUseCase.deleteFavorite(for: tvShowId)
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
    
    private func findFavorite(tvShowId: Int) {
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
                if favorites.first(where: { tvShow in tvShow.id == tvShowId }) != nil {
                    self.isFavorite = true
                } else {
                    self.isFavorite = false
                }
            }.store(in: &cancellable)
    }
    
    func toPersonView<Content: View>(
        for personId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makePersonDetailView(for: personId)) {
            content()
        }
        .buttonStyle(.plain)
    }
    
    func toCreditDetailView<Content: View>(
        for creditModel: [CreditModel],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeCreditDetailView(for: creditModel)) {
            content()
        }
    }
}
