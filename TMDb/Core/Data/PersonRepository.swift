//
//  PersonRepository.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Combine

protocol PersonRepositoryProtocol {
    func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error>
}

final class PersonRepository: NSObject {
    typealias PersonRepositoryInstance = (PersonDataSource) -> PersonRepository
    
    fileprivate let personDataSource: PersonDataSource
    
    private init(personDataSource: PersonDataSource) {
        self.personDataSource = personDataSource
    }
    
    static let sharedInstance: PersonRepositoryInstance = { personDataSource in
         return PersonRepository(personDataSource: personDataSource)
    }
}

extension PersonRepository: PersonRepositoryProtocol {
    func getPerson(personId: Int) -> AnyPublisher<PersonModel, Error> {
        return self.personDataSource.getPerson(personId: personId)
            .map {
                Mapper.mapPersonResponseToDomain(input: $0)
            }.eraseToAnyPublisher()
    }
}
