//
//  FavoritePresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import Foundation
import Observation

@MainActor
@Observable
final class FavoritePresenter {
    enum Sort: String, CaseIterable {
        case recent = "Recently added"
        case oldest = "Oldest added"
        case highestRated = "Highest rated"
        case title = "Title A–Z"
        case mostVoted = "Most voted"
    }

    private let favoriteUseCase: FavoriteUseCase

    private(set) var favorites: [FavoriteModel] = []
    private(set) var loadFailed = false
    var showsRemovalError = false
    var sort: Sort = .recent

    init(favoriteUseCase: FavoriteUseCase) {
        self.favoriteUseCase = favoriteUseCase
    }

    var sortedFavorites: [FavoriteModel] {
        favorites.sorted { left, right in
            switch sort {
            case .recent:
                break
            case .oldest:
                if left.createdAt != right.createdAt { return left.createdAt < right.createdAt }
            case .highestRated:
                let leftRating = left.id.mediaType == .person ? 0 : left.rating
                let rightRating = right.id.mediaType == .person ? 0 : right.rating
                if leftRating != rightRating { return leftRating > rightRating }
            case .title:
                let order = left.title.localizedStandardCompare(right.title)
                if order != .orderedSame { return order == .orderedAscending }
            case .mostVoted:
                let leftVotes = left.id.mediaType == .person ? -1 : (left.voteCount ?? -1)
                let rightVotes = right.id.mediaType == .person ? -1 : (right.voteCount ?? -1)
                if leftVotes != rightVotes { return leftVotes > rightVotes }
            }

            if left.createdAt != right.createdAt { return left.createdAt > right.createdAt }
            if left.id.mediaType != right.id.mediaType {
                return left.id.mediaType.rawValue < right.id.mediaType.rawValue
            }
            return left.id.mediaID < right.id.mediaID
        }
    }

    func load() {
        do {
            favorites = try favoriteUseCase.getFavorites()
            loadFailed = false
        } catch {
            loadFailed = true
        }
    }

    func remove(_ id: FavoriteModel.ID) {
        do {
            try favoriteUseCase.removeFavorite(id)
            favorites.removeAll { $0.id == id }
        } catch {
            showsRemovalError = true
        }
    }
}
