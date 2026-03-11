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
    
    private var context: ModelContext {
        SwiftDataContextManager.shared.context
    }
    
    var favorites: [FavoriteModel] = []
    
    func getFavorites() {
        let descriptor = FetchDescriptor<FavoriteEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        let entities = try? context.fetch(descriptor)
        if let _entities = entities {
            favorites = Mapper.mapFavoriteEntitiesToDomains(input: _entities)
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
