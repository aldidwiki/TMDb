import Alamofire
import Combine

enum TMDbRequest {
    static func value<Response: Decodable>(
        _ path: String,
        parameters: Parameters? = nil,
        mapError: @escaping (AFError) -> Error = { _ in URLError.invalidResponse }
    ) -> AnyPublisher<Response, Error> {
        AF.request(API.baseUrl + path, parameters: parameters, headers: API.headers)
            .validate()
            .publishDecodable(type: Response.self)
            .value()
            .mapError(mapError)
            .eraseToAnyPublisher()
    }
}
