//
//  FavoriteInteractor.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation
import Combine

protocol FavoriteUseCase: AnyObject {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never>
    func getFavorites() -> AnyPublisher<[FavoriteModel], Error>
    func isFavorited(mediaId: Int) -> AnyPublisher<Bool, Never>
}

class FavoriteInteractor: FavoriteUseCase {
    private let favoriteRepository: FavoriteRepositoryProtocol
    
    init(favoriteRepository: FavoriteRepositoryProtocol) {
        self.favoriteRepository = favoriteRepository
    }
    
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never> {
        return favoriteRepository.addToFavorite(requestModel)
    }
    
    func isFavorited(mediaId: Int) -> AnyPublisher<Bool, Never> {
        return getFavorites()
            .map { favorites in
                let favorite = favorites.first { model in
                    model.id == mediaId
                }
                
                return favorite != nil
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func getFavorites() -> AnyPublisher<[FavoriteModel], any Error> {
        return Publishers.Zip(
            favoriteRepository.getMoviesFavorite(),
            favoriteRepository.getTvsFavorite()
        )
        .map { movieResponse, tvResponse in
            let movieFavorites = movieResponse.movies.map { movieResponseModel in
                FavoriteModel(
                    id: movieResponseModel.id,
                    title: movieResponseModel.title,
                    posterPath: movieResponseModel.posterPath ?? "",
                    rating: movieResponseModel.rating ?? 0.0,
                    releaseDate: movieResponseModel.releaseDate ?? "",
                    mediaType: Constants.movieType
                )
            }
            
            let tvFavorites = tvResponse.tvShows.map { tvResponseModel in
                FavoriteModel(
                    id: tvResponseModel.id,
                    title: tvResponseModel.title,
                    posterPath: tvResponseModel.posterPath ?? "",
                    rating: tvResponseModel.rating ?? 0.0,
                    releaseDate: tvResponseModel.releaseDate ?? "",
                    mediaType: Constants.tvType
                )
            }
            
            return movieFavorites + tvFavorites
        }
        .eraseToAnyPublisher()
    }
}
