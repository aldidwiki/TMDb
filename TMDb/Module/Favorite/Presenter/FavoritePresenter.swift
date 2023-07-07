//
//  FavoritePresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import Combine

class FavoritePresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = FavoriteRouter()
    private let favoriteUseCase: FavoriteUseCase
    
    @Published var favorites = [FavoriteModel]()
    @Published var errorMessage = ""
    @Published var loadingState = false
    
    init(favoriteUseCase: FavoriteUseCase) {
        self.favoriteUseCase = favoriteUseCase
    }
    
    func getFavorites() {
        self.loadingState = true
        favoriteUseCase.getFavorites()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { favorites in
                self.favorites = favorites
            }.store(in: &cancellable)
    }
    
    func linkBuilder<Content: View>(
        for favoriteModel: FavoriteModel,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink {
            if favoriteModel.mediaType == Constants.movieType {
                router.makeDetailView(movieId: favoriteModel.id)
            } else if favoriteModel.mediaType == Constants.tvType {
                router.makeTvDetailView(tvShowId: favoriteModel.id)
            }
        } label: {
            content()
        }
    }
}
