//
//  PersonDataSource.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Combine

protocol PersonDataSourceProtocol {
    func getPerson(personId: Int) -> AnyPublisher<PersonResponse, Error>
    func getPersonImage(personId: Int) -> AnyPublisher<ImageResponse, Error>
}

final class PersonDataSource: NSObject {
    private override init() {}

    static let sharedInstance: PersonDataSource = PersonDataSource()
}

extension PersonDataSource: PersonDataSourceProtocol {
    func getPerson(personId: Int) -> AnyPublisher<PersonResponse, Error> {
        TMDbRequest.value("person/\(personId)", parameters: ["append_to_response": "combined_credits,external_ids"])
    }

    
    func getPersonImage(personId: Int) -> AnyPublisher<ImageResponse, Error> {
        TMDbRequest.value("person/\(personId)/images")
    }
}
