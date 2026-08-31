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
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never>
}

final class FavoriteDataSource: NSObject {
    private override init() {}
    
    static let sharedInstance = FavoriteDataSource()
}

extension FavoriteDataSource: FavoriteDataSourceProtocol {
    func addToFavorite(_ requestModel: FavoriteRequest) -> AnyPublisher<Bool, Never> {
        guard let url = URL(string: API.baseUrl + "account/\(API.accountId)/favorite") else {
            return Empty<Bool, Never>().eraseToAnyPublisher()
        }
        
        return Future<Bool, Never> { promise in
            AF.request(
                url,
                method: .post,
                parameters: requestModel,
                encoder: JSONParameterEncoder.default,
                headers: API.headers
            )
            .responseDecodable(of: FavoriteResponse.self) { response in
                switch response.result {
                case .success(let value):
                    promise(.success(value.success))
                case .failure(let error):
                    break
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
