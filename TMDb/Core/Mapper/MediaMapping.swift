import Foundation

extension Mapper {
    static func joinedCreditNames(_ names: [String?]) -> String? {
        var seen: Set<String> = []
        let uniqueNames = names.compactMap { name -> String? in
            guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty, seen.insert(name).inserted else { return nil }
            return name
        }
        return uniqueNames.isEmpty ? nil : uniqueNames.joined(separator: ", ")
    }

    static func mapImageResponseToImageDomains(
        input imageResponse: ImageResponse
    ) -> [ImageModel] {
        guard let backdrops = imageResponse.backdrops else {
            return []
        }

        return backdrops.map { imageResponseModel in
            ImageModel(
                id: imageResponse.imageId,
                filePath: imageResponseModel.filePath ?? "",
                aspectRatio: imageResponseModel.aspectRatio
            )
        }
    }

    static func mapVideoResponseModelToDomains(
        input videoResponse: VideoResponse
    ) -> [VideoModel] {
        return videoResponse.results.map { video in
            VideoModel(
                id: video.id,
                key: video.key,
                name: video.name,
                site: video.site,
                type: video.type
            )
        }
        .filter { video in
            video.site == "YouTube" && video.type == "Trailer"
        }
        .sorted {
            $0.name < $1.name
        }
    }
}
