import Foundation

enum PosterURLType {
    case movie(path: String), tv(path: String)
    case person(path: String)

    var url: URL? {
        switch self {
        case .movie(let path), .tv(let path):
            return URL(string: API.imageBaseUrl + path)
        case .person(let path):
            return URL(string: API.profileImageBaseUrl + path)
        }
    }
}
