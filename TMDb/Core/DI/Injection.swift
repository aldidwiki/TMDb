//
//  Injection.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import CorePackage
import RealmSwift
import FavoritePackage
import Foundation

final class Injection: NSObject {
    private func provideRepository() -> TMDbRepositoryProtocol {
        let realm = CoreInjection.init().provideRealm()
        
        let remote = RemoteDataSource.sharedInstance
        let locale = LocaleDataSource.sharedInstance(realm)
        
        return TMDbRepository.sharedInstance(remote, locale)
    }
    
    func provideHomeUseCase() -> HomeUseCase {
        let repo = provideRepository()
        return HomeInteractor(repository: repo)
    }
    
    func provideDetailUseCase(movieId: Int) -> DetailUseCase {
        let repo = provideRepository()
        return DetailInteractor(repository: repo, movieId: movieId)
    }
}
