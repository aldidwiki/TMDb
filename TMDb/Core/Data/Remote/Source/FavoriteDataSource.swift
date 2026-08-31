//
//  FavoriteDataSource.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation
import Alamofire
import Combine

protocol FavoriteDataSourceProtocol: AnyObject {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<String, Error>
}

final class FavoriteDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance = FavoriteDataSource()
}

extension FavoriteDataSource: FavoriteDataSourceProtocol {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<String, any Error> {
        guard let url = URL(string: API.baseUrl + "account/\(API.accountId)/favorite") else {
            return Empty<String, Error>().eraseToAnyPublisher()
        }
        
        return Future<String, Error> { promise in
            AF.request(url, method: .post, parameters: requestModel, encoder: JSONParameterEncoder.default)
                .responseDecodable(of: FavoriteResponse.self) { response in
                    switch response.result {
                    case .success(let value):
                        promise(.success(value.statusMessage))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
