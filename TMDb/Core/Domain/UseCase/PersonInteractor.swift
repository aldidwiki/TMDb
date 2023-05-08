//
//  PersonInteractor.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import Combine

protocol PersonUseCase {
    func getPerson() -> AnyPublisher<PersonModel, Error>
}

class PersonInteractor: PersonUseCase {
    private let repository: TMDbRepositoryProtocol
    private let personId: Int
    
    required init(repository: TMDbRepositoryProtocol, personId: Int) {
        self.repository = repository
        self.personId = personId
    }
    
    func getPerson() -> AnyPublisher<PersonModel, Error> {
        return repository.getPerson(personId: self.personId)
    }
}
