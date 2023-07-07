//
//  Injection.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import RealmSwift

final class Injection: NSObject {
    private func provideMovieRepository() -> MovieRepositoryProtocol {
        let movieDataSource = MovieDataSource.sharedInstance
        
        return MovieRepository.sharedInstance(movieDataSource)
    }
    
    private func provideFavoriteRepository() -> FavoriteRepositoryProtocol {
        let realm = try? Realm()
        let localDataSource = LocaleDataSource.sharedInstance(realm)
        
        return FavoriteRepository.sharedInstance(localDataSource)
    }
    
    private func providePersonRepository() -> PersonRepositoryProtocol {
        let personDataSource = PersonDataSource.sharedInstance
        
        return PersonRepository.sharedInstance(personDataSource)
    }
    
    private func provideTvShowRepository() -> TvShowRepositoryProtocol {
        let tvShowDataSource = TvShowDataSource.sharedInstance
        
        return TvShowRepository.sharedInstance(tvShowDataSource)
    }
    
    func provideMovieUseCase() -> MovieUseCase {
        let repo = provideMovieRepository()
        return MovieInteractor(repository: repo)
    }
    
    func provideDetailUseCase(movieId: Int) -> DetailUseCase {
        let repo = provideMovieRepository()
        return DetailInteractor(repository: repo, movieId: movieId)
    }
    
    func provideFavoriteUseCase() -> FavoriteUseCase {
        let repo = provideFavoriteRepository()
        return FavoriteInteractor(repository: repo)
    }
    
    func providePersonUseCase(personId: Int) -> PersonUseCase {
        let repo = providePersonRepository()
        return PersonInteractor(repository: repo, personId: personId)
    }
    
    func provideTvShowUseCase() -> TvShowUseCase {
        let repo = provideTvShowRepository()
        return TvShowInteractor(repository: repo)
    }
}
