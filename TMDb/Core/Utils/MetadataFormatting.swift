extension [GenreResponseModel] {
    func formatGenres() -> String {
        var genres = ""
        let sortedGenre = self.sorted { genre1, genre2 in
            genre1.genreName < genre2.genreName
        }
        for genre in sortedGenre {
            if genre == sortedGenre.last {
                genres += "\(genre.genreName)"
            } else {
                genres += "\(genre.genreName), "
            }
        }

        return genres
    }
}

extension [SpokenLanguageResponse] {
    func formatSpokenLanguage() -> String {
        var spokenLanguage = ""
        for spokenLangRes in self {
            spokenLanguage += spokenLangRes.englishName ?? ""
            if spokenLangRes.englishName != self.last?.englishName {
                spokenLanguage += "\n"
            }
        }

        return spokenLanguage
    }
}
