//
//  PersonInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import Combine

protocol PersonUseCase {
    func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error>
    func getPopularPerson(page: Int) -> AnyPublisher<[PersonPopularModel], Error>
    func getPersonImage(personId: Int) -> AnyPublisher<[PersonImageModel], Error>
}

class PersonInteractor: PersonUseCase {
    private let repository: PersonRepositoryProtocol
    
    required init(repository: PersonRepositoryProtocol) {
        self.repository = repository
    }
    
    func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error> {
        return repository.getPerson(personId: personId)
    }
    
    func getPopularPerson(page: Int) -> AnyPublisher<[PersonPopularModel], Error> {
        return repository.getPopularPerson(page: page)
    }
    
    func getPersonImage(personId: Int) -> AnyPublisher<[PersonImageModel], Error> {
        return repository.getPersonImages(personId: personId)
    }
}
