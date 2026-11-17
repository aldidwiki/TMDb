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
    
    
    func getPersonImage(personId: Int) -> AnyPublisher<[PersonImageModel], Error> {
        return repository.getPersonImages(personId: personId)
    }
}
