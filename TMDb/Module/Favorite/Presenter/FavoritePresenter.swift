//
//  FavoritePresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import Combine
import Observation

@Observable
class FavoritePresenter {
    private let router = FavoriteRouter()
    private let favoriteUseCase: FavoriteUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    init(favoriteUseCase: FavoriteUseCase) {
        self.favoriteUseCase = favoriteUseCase
    }
    
    var favorites: [FavoriteModel] = []
    var isLoading = true
    
    func getFavorites() async {
        let favorites = await withCheckedContinuation { continuation in
            favoriteUseCase.getFavorites()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        self?.isLoading = false
                    }
                } receiveValue: { favorites in
                    continuation.resume(returning: favorites)
                }
                .store(in: &cancellables)
        }
        
        self.favorites = favorites
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
            } else if favoriteModel.mediaType == Constants.personType {
                router.makePersonDetailView(personId: favoriteModel.id)
            }
        } label: {
            content()
        }
        .buttonStyle(.plain)
    }
}
