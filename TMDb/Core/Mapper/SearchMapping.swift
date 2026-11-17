import Foundation

extension Mapper {
    static func mapSearchResponseModelToDomains(
        input responseModel: [SearchResponseModel]
    ) -> [SearchModel] {
        return responseModel.compactMap { model in
            guard let mediaType = model.mediaType.flatMap(SearchModel.MediaType.init(rawValue:)) else {
                return nil
            }
            return SearchModel(
                id: .init(mediaType: mediaType, value: model.id),
                name: model.title ?? model.name ?? "",
                releaseDate: model.releaseDate ?? model.firstAirDate ?? "",
                imagePath: model.posterPath ?? model.profilePath ?? "",
                voteAverage: model.voteAverage,
                overview: model.overview ?? "",
                knownForDepartment: model.knownForDepartment ?? ""
            )
        }
    }
}
