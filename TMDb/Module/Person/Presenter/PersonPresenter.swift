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
import SwiftData

@MainActor
@Observable
class PersonPresenter {
    struct KnownForItem: Identifiable {
        let id: PersonRouter.CreditRoute
        let credit: CreditModel
    }

    struct ProfileLink: Identifiable {
        let title: String
        let url: URL

        var id: String { title }
    }

    private var cancellable: Set<AnyCancellable> = []
    
    private let personUseCase: PersonUseCase
    private let router = PersonRouter()
    private let personRouter = DetailRouter()
    
    var isFavorite = false
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
    
    private var context: ModelContext {
        SwiftDataContextManager.shared.context
    }
    
    init(personUseCase: PersonUseCase) {
        self.personUseCase = personUseCase
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
        self.loadingState = true
        personUseCase.getPersonImage(personId: personId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.loadingState = false
                }
            } receiveValue: { personImageResult in
                self.personImages = personImageResult
            }.store(in: &cancellable)
    }
    
    func checkFavoriteStatus(personId: Int) {
        let descriptor = FetchDescriptor(predicate: #Predicate<FavoriteEntity> { $0.id == personId })
        let result = (try? context.fetch(descriptor)) ?? []
        isFavorite = !result.isEmpty
    }
    
    func toggleFavorite() {
        if isFavorite {
            deleteFavorite()
        } else {
            addFavorite()
        }
    }
    
    private func addFavorite() {
        context.insert(Mapper.mapPersonModelToFavoriteEntity(input: person))
        isFavorite = true
    }
    
    private func deleteFavorite() {
        let personId = person.id // Assuming your movie model has an id
        
        // 1. Create a predicate to find the EXISTING entity
        let predicate = #Predicate<FavoriteEntity> { favorite in
            favorite.id == personId
        }
        
        // 2. Fetch the entity from the context
        let descriptor = FetchDescriptor<FavoriteEntity>(predicate: predicate)
        
        do {
            // 3. If it exists in the DB, delete THAT specific instance
            if let entityToDelete = try context.fetch(descriptor).first {
                context.delete(entityToDelete)
                isFavorite = false
                // try context.save() // Optional: force the write
            }
        } catch {
            print("Failed to fetch favorite for deletion: \(error)")
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
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makePersonImageView(personId: personId).toolbar(.visible, for: .navigationBar)) {
            content()
        }
        .buttonStyle(.plain)
    }
}
