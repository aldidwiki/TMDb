//
//  FavoritePresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import Combine
import Observation
import SwiftData

@MainActor
@Observable
class FavoritePresenter {
    private let router = FavoriteRouter()
    private let favoriteUseCase: FavoriteUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    private var context: ModelContext {
        SwiftDataContextManager.shared.context
    }
    
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
        getFavoritesFromLocal()
    }
    
    private func getFavoritesFromLocal() {
        let personType = Constants.personType
        let filteredPredicate = #Predicate<FavoriteEntity> { entity in
            entity.mediaType == personType
        }
        
        let descriptor = FetchDescriptor<FavoriteEntity>(
            predicate: filteredPredicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        let entities = try? context.fetch(descriptor)
        if let entityList = entities {
            favorites += Mapper.mapFavoriteEntitiesToDomains(input: entityList)
        }
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
