//
//  PersonPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import Observation
import Combine
import SwiftUI

@MainActor
@Observable
class PersonPresenter {
    struct KnownForItem: Identifiable {
        let id: PersonRouter.CreditRoute
        let credit: CreditModel
    }

    struct CreditListItem: Identifiable {
        let id: PersonRouter.CreditRoute
        let title: String
        let releaseYear: String?
        var posterPath: String
        var roles: [String]
        var episodeCount: Int
    }

    struct ProfileLink: Identifiable {
        let title: String
        let url: URL

        var id: String { title }
    }

    private var cancellable: Set<AnyCancellable> = []
    
    private let personUseCase: PersonUseCase
    private let favoriteUseCase: FavoriteUseCase
    private let router = PersonRouter()
    private let personRouter = DetailRouter()
    
    var isFavorite = false
    var showsFavoriteError = false
    var errorMessage = ""
    var loadingState = false
    var person = PersonModel(
        id: 0,
        name: "",
        profilePath: "",
        birthday: "",
        deathday: "",
        gender: "Unknown",
        biography: "",
        birthplace: "",
        knownFor: "",
        alsoKnownAs: [],
        credits: [],
        instagramId: "",
        facebookId: "",
        imdbId: "",
        twitterId: ""
    )
    
    var personPopular: [PersonPopularModel] = []
    var personImages: [PersonImageModel] = []
    
    var isFetchingMore = false
    private var canLoadMore = true
    private var currentPage = 1
    
    init(personUseCase: PersonUseCase, favoriteUseCase: FavoriteUseCase = Injection().provideFavoriteUseCase()) {
        self.personUseCase = personUseCase
        self.favoriteUseCase = favoriteUseCase
    }

    func getPerson(personId: Int) {
        guard !loadingState else { return }
        loadingState = true
        errorMessage = ""
        personUseCase.getPerson(personId: personId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.loadingState = false
                if case .failure = completion {
                    self?.errorMessage = "Couldn’t load person details"
                }
            } receiveValue: { [weak self] person in
                self?.person = person
            }.store(in: &cancellable)
    }

    var knownForItems: [KnownForItem] {
        var items: [KnownForItem] = []
        var seen: Set<PersonRouter.CreditRoute> = []
        for credit in person.credits.sorted(by: { $0.popularity > $1.popularity }) {
            guard credit.id > 0, !credit.name.isEmpty,
                  let route = PersonRouter.CreditRoute(credit: credit),
                  seen.insert(route).inserted else { continue }
            items.append(KnownForItem(id: route, credit: credit))
            if items.count == 10 { break }
        }
        return items
    }

    var allCreditItems: [CreditListItem] {
        var items: [CreditListItem] = []
        var indexByRoute: [PersonRouter.CreditRoute: Int] = [:]

        for credit in person.credits.sorted(by: { $0.releaseDate > $1.releaseDate }) {
            let title = credit.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard credit.id > 0, !title.isEmpty,
                  let route = PersonRouter.CreditRoute(credit: credit) else { continue }

            let role = credit.characterName.trimmingCharacters(in: .whitespacesAndNewlines)
            let posterPath = credit.profilePath.trimmingCharacters(in: .whitespacesAndNewlines)
            let roleLabel = credit.isCrewCredit ? role : "as \(role)"
            let hasRole = !role.isEmpty && role != "-"

            if let index = indexByRoute[route] {
                if hasRole && !items[index].roles.contains(roleLabel) {
                    items[index].roles.append(roleLabel)
                }
                if items[index].posterPath.isEmpty {
                    items[index].posterPath = posterPath
                }
                // Different roles may cover the same episodes.
                items[index].episodeCount = max(items[index].episodeCount, credit.episodeCount)
            } else {
                let year = String(credit.releaseDate.prefix(4))
                indexByRoute[route] = items.count
                items.append(CreditListItem(
                    id: route,
                    title: title,
                    releaseYear: year.count == 4 && (Int(year) ?? 0) > 0 ? year : nil,
                    posterPath: posterPath,
                    roles: hasRole ? [roleLabel] : [],
                    episodeCount: credit.episodeCount
                ))
            }
        }

        return items
    }

    var profileLinks: [ProfileLink] {
        let instagram = person.instagramId.trimmingCharacters(in: .whitespacesAndNewlines)
        let imdb = person.imdbId.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        var links: [ProfileLink] = []

        if instagram.wholeMatch(of: #/[A-Za-z0-9_][A-Za-z0-9_.]{0,29}/#) != nil,
           !instagram.hasSuffix("."), !instagram.contains(".."),
           let url = URL(string: "https://www.instagram.com/\(instagram)/") {
            links.append(ProfileLink(title: "Instagram", url: url))
        }

        if imdb.wholeMatch(of: #/nm[0-9]{7,}/#) != nil,
           let url = URL(string: "https://www.imdb.com/name/\(imdb)/") {
            links.append(ProfileLink(title: "IMDb", url: url))
        }

        if !name.isEmpty, name != "-" {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "www.google.com"
            components.path = "/search"
            components.queryItems = [URLQueryItem(name: "q", value: name)]
            // Google treats a literal plus as a space in query parameters.
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            if let url = components.url {
                links.append(ProfileLink(title: "Google", url: url))
            }
        }

        return links
    }
    
    func getPopularPerson(reset: Bool = false) {
        if reset {
            currentPage = 1
            loadingState = true
            canLoadMore = true
            personPopular.removeAll()
        }
        
        guard canLoadMore && !isFetchingMore else { return }
        
        if currentPage > 1 {
            isFetchingMore = true
        }
        
        personUseCase.getPopularPerson(page: currentPage)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.isFetchingMore = false
                }
            } receiveValue: { newPersons in
                let uniquePersons = newPersons.filter { newPerson in
                    !self.personPopular.contains { $0.id == newPerson.id }
                }
                
                if uniquePersons.isEmpty {
                    self.canLoadMore = false
                    
                    if self.currentPage == 1 {
                        self.loadingState = false
                        self.personPopular = newPersons
                    }
                } else {
                    if reset {
                        self.personPopular = uniquePersons
                    } else {
                        self.personPopular.append(contentsOf: uniquePersons)
                    }
                    
                    if self.currentPage == 1 {
                        self.loadingState = false
                    }
                    
                    self.currentPage += 1
                }
            }.store(in: &cancellable)
    }
    
    func getPersonImage(personId: Int) {
        guard !loadingState else { return }
        loadingState = true
        errorMessage = ""
        personUseCase.getPersonImage(personId: personId)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.loadingState = false
                if case .failure = completion {
                    self?.errorMessage = "Couldn’t load photos"
                }
            } receiveValue: { [weak self] images in
                self?.personImages = images
            }.store(in: &cancellable)
    }
    
    func checkFavoriteStatus(personId: Int) {
        do {
            isFavorite = try favoriteUseCase.isFavorited(.init(mediaType: .person, mediaID: personId))
        } catch {
            showsFavoriteError = true
        }
    }

    func toggleFavorite() {
        guard person.id > 0 else { return }
        do {
            isFavorite = try favoriteUseCase.toggleFavorite(Mapper.mapPersonToFavorite(person))
        } catch {
            showsFavoriteError = true
        }
    }

    func toPersonDetailView<Content: View>(
        personId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: personRouter.makePersonDetailView(for: personId)) {
            content()
        }
        .buttonStyle(.plain)
    }
    
    func toPersonImageView<Content: View>(
        personId: Int,
        personName: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makePersonImageView(personId: personId, personName: personName)) {
            content()
        }
        .buttonStyle(.plain)
    }
}
