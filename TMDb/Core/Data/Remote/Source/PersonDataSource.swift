//
//  PersonDataSource.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Alamofire
import Combine

protocol PersonDataSourceProtocol {
    func getPerson(personId: Int) -> AnyPublisher<PersonResponse, Error>
    func getPopularPerson() -> AnyPublisher<PersonPopularResponse, Error>
    func getPersonImage(personId: Int) -> AnyPublisher<ImageResponse, Error>
}

final class PersonDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance: PersonDataSource = PersonDataSource()
}

extension PersonDataSource: PersonDataSourceProtocol {
    func getPerson(personId: Int) -> AnyPublisher<PersonResponse, Error> {
        let param: Parameters = [
            "append_to_response": "combined_credits,external_ids"
        ]
        
        return Future<PersonResponse, Error> {completion in
            if let url = URL(string: "\(API.baseUrl)person/\(personId)") {
                AF.request(url, parameters: param, headers: API.headers)
                    .validate()
                    .responseDecodable(of: PersonResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value))
                            case .failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    func getPopularPerson() -> AnyPublisher<PersonPopularResponse, Error> {
        return Future<PersonPopularResponse, Error> { completion in
            if let url = URL(string: "\(API.baseUrl)person/popular") {
                AF.request(url, headers: API.headers)
                    .validate()
                    .responseDecodable(of: PersonPopularResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value))
                            case .failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    func getPersonImage(personId: Int) -> AnyPublisher<ImageResponse, Error> {
        return Future<ImageResponse, Error> { completion in
            if let url = URL(string: "\(API.baseUrl)/person/\(personId)/images") {
                AF.request(url, headers: API.headers)
                    .validate()
                    .responseDecodable(of: ImageResponse.self) { response in
                        switch response.result {
                            case .success(let value):
                                completion(.success(value))
                            case .failure:
                                completion(.failure(URLError.invalidResponse))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
}
