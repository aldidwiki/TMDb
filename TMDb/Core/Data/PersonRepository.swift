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
    func getPopularPerson() -> AnyPublisher<[PersonPopularModel], Error>
    func getPersonImages(personId: Int) -> AnyPublisher<[PersonImageModel], Error>
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
    
    func getPopularPerson() -> AnyPublisher<[PersonPopularModel], Error> {
        return self.personDataSource.getPopularPerson()
            .map {
                Mapper.mapPersonPopularResponseToDomains(input: $0)
            }.eraseToAnyPublisher()
    }
    
    func getPersonImages(personId: Int) -> AnyPublisher<[PersonImageModel], Error> {
        return self.personDataSource.getPersonImage(personId: personId)
            .map { imageResponse in
                Mapper.mapImageResponseToPersonImageDomains(input: imageResponse)
            }.eraseToAnyPublisher()
    }
}
