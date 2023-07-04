//
//  Injection.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import RealmSwift

final class Injection: NSObject {
    private func provideRepository() -> MovieRepositoryProtocol {
        let realm = try? Realm()
        
        let movieDataSource = MovieDataSource.sharedInstance
        let locale = LocaleDataSource.sharedInstance(realm)
        
        return MovieRepository.sharedInstance(movieDataSource, locale)
    }
    
    private func providePersonRepository() -> PersonRepositoryProtocol {
        let personDataSource = PersonDataSource.sharedInstance
        
        return PersonRepository.sharedInstance(personDataSource)
    }
    
    func provideMovieUseCase() -> MovieUseCase {
        let repo = provideRepository()
        return MovieInteractor(repository: repo)
    }
    
    func provideDetailUseCase(movieId: Int) -> DetailUseCase {
        let repo = provideRepository()
        return DetailInteractor(repository: repo, movieId: movieId)
    }
    
    func provideFavoriteUseCase() -> FavoriteUseCase {
        let repo = provideRepository()
        return FavoriteInteractor(repository: repo)
    }
    
    func providePersonUseCase(personId: Int) -> PersonUseCase {
        let repo = providePersonRepository()
        return PersonInteractor(repository: repo, personId: personId)
    }
    
    func provideTvShowUseCase() -> TvShowUseCase {
        let repo = provideRepository()
        return TvShowInteractor(repository: repo)
    }
}
