//
//  FavoriteInteractor.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

protocol FavoriteUseCase: AnyObject {
    @MainActor func getFavorites() throws -> [FavoriteModel]
    @MainActor func isFavorited(_ id: FavoriteModel.ID) throws -> Bool
    @MainActor func toggleFavorite(_ favorite: FavoriteModel) throws -> Bool
    @MainActor func removeFavorite(_ id: FavoriteModel.ID) throws
}

final class FavoriteInteractor: FavoriteUseCase {
    private let favoriteRepository: FavoriteRepositoryProtocol

    init(favoriteRepository: FavoriteRepositoryProtocol) {
        self.favoriteRepository = favoriteRepository
    }

    @MainActor
    func getFavorites() throws -> [FavoriteModel] {
        try favoriteRepository.getFavorites()
    }

    @MainActor
    func isFavorited(_ id: FavoriteModel.ID) throws -> Bool {
        try favoriteRepository.isFavorited(id)
    }

    @MainActor
    func toggleFavorite(_ favorite: FavoriteModel) throws -> Bool {
        if try isFavorited(favorite.id) {
            try favoriteRepository.remove(favorite.id)
            return false
        }

        try favoriteRepository.save(favorite)
        return true
    }

    @MainActor
    func removeFavorite(_ id: FavoriteModel.ID) throws {
        try favoriteRepository.remove(id)
    }
}
