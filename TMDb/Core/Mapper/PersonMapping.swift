import Foundation

extension Mapper {
    static func mapPersonResponseToDomain(
        input personResponse: PersonResponse
    ) -> PersonModel {
        var genderText = "Unknown"
        if personResponse.gender == 1 {
            genderText = "Female"
        } else if personResponse.gender == 2 {
            genderText = "Male"
        }

        return PersonModel(
            id: personResponse.id,
            name: personResponse.name ?? "",
            profilePath: personResponse.profilePath ?? "",
            birthday: personResponse.birthday ?? "-",
            deathday: personResponse.deathday ?? "",
            gender: genderText,
            biography: personResponse.biography ?? "-",
            birthplace: personResponse.birthplace ?? "-",
            knownFor: personResponse.knownFor ?? "-",
            alsoKnownAs: personResponse.alsoKnownAs ?? [],
            credits: mapPersonCreditResponseToDomains(input: personResponse),
            instagramId: personResponse.externalMedia?.instagramId ?? "",
            facebookId: personResponse.externalMedia?.facebookId ?? "",
            imdbId: personResponse.externalMedia?.imdbId ?? personResponse.imdbId ?? "",
            twitterId: personResponse.externalMedia?.twitterId ?? ""
        )
    }

    static func mapImageResponseToPersonImageDomains(
        input imageResponse: ImageResponse
    ) -> [PersonImageModel] {
        guard let profileImages = imageResponse.profileImages else {
            return []
        }

        var seen: Set<String> = []
        return profileImages.compactMap { image in
            guard let path = image.filePath, path.hasPrefix("/"), path.count > 1,
                  seen.insert(path).inserted else { return nil }
            return PersonImageModel(filePath: path, aspectRatio: image.aspectRatio)
        }
    }

    private static func mapPersonCreditResponseToDomains(
        input personResponse: PersonResponse
    ) -> [CreditModel] {
        let cast = (personResponse.credits?.cast ?? []).map { ($0, false) }
        let crew = (personResponse.credits?.crew ?? []).map { ($0, true) }
        return (cast + crew).map { credit, isCrewCredit in
            CreditModel(
                id: credit.id,
                name: credit.movieTitle ?? credit.tvTitle ?? "",
                profilePath: credit.posterPath ?? "",
                characterName: credit.characterName ?? credit.job ?? "",
                order: credit.order ?? 0,
                popularity: credit.popularity ?? 0,
                releaseDate: credit.releaseDate ?? credit.firstAirDate ?? "",
                episodeCount: credit.mediaType == Constants.tvShowResponseType && !isCrewCredit
                    ? (credit.episodeCount ?? 0)
                    : 0,
                mediaType: credit.mediaType,
                isCrewCredit: isCrewCredit
            )
        }.sorted {
            $0.releaseDate > $1.releaseDate
        }
    }
}
