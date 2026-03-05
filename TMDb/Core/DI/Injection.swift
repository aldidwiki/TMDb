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
    
    private func providePersonRepository() -> PersonRepositoryProtocol {
        let personDataSource = PersonDataSource.sharedInstance
        
        return PersonRepository.sharedInstance(personDataSource)
    }
    
    private func provideTvShowRepository() -> TvShowRepositoryProtocol {
        let tvShowDataSource = TvShowDataSource.sharedInstance
        
        return TvShowRepository.sharedInstance(tvShowDataSource)
    }
    
    private func provideSearchRepository() -> SearchRepositoryProtocol {
        let searchDataSource = SearchDataSource.sharedInstance
        
        return SearchRepository.sharedInstance(searchDataSource)
    }
    
    func provideMovieUseCase() -> MovieUseCase {
        let repo = provideMovieRepository()
        return MovieInteractor(repository: repo)
    }
    
    func provideDetailUseCase() -> DetailUseCase {
        let repo = provideMovieRepository()
        return DetailInteractor(repository: repo)
    }
    
    func providePersonUseCase() -> PersonUseCase {
        let repo = providePersonRepository()
        return PersonInteractor(repository: repo)
    }
    
    func provideTvShowUseCase() -> TvShowUseCase {
        let repo = provideTvShowRepository()
        return TvShowInteractor(repository: repo)
    }
    
    func provideSearchUseCase() -> SearchUseCase {
        let repo = provideSearchRepository()
        return SearchInteractor(searchRepository: repo)
    }
}
