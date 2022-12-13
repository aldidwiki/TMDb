//
//  FavoriteDataSource.swift
//  Favorite
//
//  Created by Aldi Dwiki Prahasta on 13/12/22.
//

import RealmSwift
import Combine
import CorePackage
import Foundation

protocol FavoriteDataSourceProtocol {
    func getFavorites() -> AnyPublisher<[FavoriteEntity], Error>
    func addFavorite(movie: FavoriteEntity) -> AnyPublisher<Bool, Error>
    func deleteFavorite(from movieId: Int) -> AnyPublisher<Bool, Error>
}

final class FavoriteDataSource: NSObject {
    private let realm: Realm?
    private init(realm: Realm?) {
        self.realm = realm
    }
    
    static let sharedInstance: (Realm?) -> FavoriteDataSource = { realmDatabase in
        return FavoriteDataSource(realm: realmDatabase)
    }
}

extension FavoriteDataSource: FavoriteDataSourceProtocol {
    func getFavorites() -> AnyPublisher<[FavoriteEntity], Error> {
        return Future<[FavoriteEntity], Error> { completion in
            if let realm = self.realm {
                let favorites: Results<FavoriteEntity> = {
                    realm.objects(FavoriteEntity.self)
                        .sorted(byKeyPath: "title", ascending: true)
                }()
                completion(.success(favorites.toArray(ofType: FavoriteEntity.self)))
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
    
    func addFavorite(movie: FavoriteEntity) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { completion in
            if let realm = self.realm {
                do {
                    try realm.write({
                        realm.add(movie, update: .all)
                        completion(.success(true))
                    })
                } catch {
                    completion(.failure(DatabaseError.requestFailed))
                }
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteFavorite(from movieId: Int) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { completion in
            if let realm = self.realm {
                do {
                    try realm.write({
                        let movie = realm.objects(FavoriteEntity.self).where {
                            $0.id == movieId
                        }
                        realm.delete(movie)
                        completion(.success(true))
                    })
                } catch {
                    completion(.failure(DatabaseError.requestFailed))
                }
            } else {
                completion(.failure(DatabaseError.invalidInstance))
            }
        }.eraseToAnyPublisher()
    }
}

extension Results {
    public func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for index in 0 ..< count {
            if let result = self[index] as? T {
                array.append(result)
            }
        }
        return array
    }
}
