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
    func getPopularPerson() -> AnyPublisher<[PersonPopularModel], Error>
    func searchPerson(query: String) -> AnyPublisher<[PersonPopularModel], Error>
}

class PersonInteractor: PersonUseCase {
    private let repository: PersonRepositoryProtocol
    
    required init(repository: PersonRepositoryProtocol) {
        self.repository = repository
    }
    
    func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error> {
        return repository.getPerson(personId: personId)
    }
    
    func getPopularPerson() -> AnyPublisher<[PersonPopularModel], Error> {
        return repository.getPopularPerson()
    }
    
    func searchPerson(query: String) -> AnyPublisher<[PersonPopularModel], Error> {
        return repository.searchPerson(query: query)
    }
}
