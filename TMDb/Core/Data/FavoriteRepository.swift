//
//  FavoriteRepository.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation
import SwiftData

protocol FavoriteRepositoryProtocol {
    @MainActor func getFavorites() throws -> [FavoriteModel]
    @MainActor func isFavorited(_ id: FavoriteModel.ID) throws -> Bool
    @MainActor func save(_ favorite: FavoriteModel) throws
    @MainActor func remove(_ id: FavoriteModel.ID) throws
}

final class FavoriteRepository: FavoriteRepositoryProtocol {
    private let contextProvider: @MainActor () -> ModelContext

    init(contextProvider: @escaping @MainActor () -> ModelContext = { SwiftDataContextManager.shared.context }) {
        self.contextProvider = contextProvider
    }

    @MainActor
    func getFavorites() throws -> [FavoriteModel] {
        let descriptor = FetchDescriptor<FavoriteEntity>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let entities = try contextProvider().fetch(descriptor)
        return Mapper.mapFavoriteEntitiesToDomains(input: entities)
    }

    @MainActor
    func isFavorited(_ id: FavoriteModel.ID) throws -> Bool {
        try !entities(for: id, in: contextProvider()).isEmpty
    }

    @MainActor
    func save(_ favorite: FavoriteModel) throws {
        let context = contextProvider()
        guard try entities(for: favorite.id, in: context).isEmpty else { return }

        context.insert(FavoriteEntity(
            id: favorite.id.mediaID,
            title: favorite.title,
            posterPath: favorite.posterPath,
            releasedDate: favorite.releaseDate,
            rating: favorite.rating,
            mediaType: favorite.id.mediaType.rawValue,
            createdAt: favorite.createdAt,
            overview: favorite.overview,
            voteCount: favorite.voteCount,
            department: favorite.department
        ))
        try commit(context)
    }

    @MainActor
    func remove(_ id: FavoriteModel.ID) throws {
        let context = contextProvider()
        let favorites = try entities(for: id, in: context)
        guard !favorites.isEmpty else { return }

        for favorite in favorites {
            context.delete(favorite)
        }
        try commit(context)
    }

    @MainActor
    private func entities(for id: FavoriteModel.ID, in context: ModelContext) throws -> [FavoriteEntity] {
        let mediaID = id.mediaID
        let mediaType = id.mediaType.rawValue
        let descriptor = FetchDescriptor<FavoriteEntity>(
            predicate: #Predicate { $0.id == mediaID && $0.mediaType == mediaType }
        )
        return try context.fetch(descriptor)
    }

    @MainActor
    private func commit(_ context: ModelContext) throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
