//
//  PersonPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import Combine
import SwiftUI

class PersonPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let personUseCase: PersonUseCase
    private let router = PersonRouter()
    private let personRouter = DetailRouter()
    
    @Published var errorMessage = ""
    @Published var loadingState = false
    @Published var isFavorite = false
    @Published var person = PersonModel(
        id: 73457,
        name: "",
        profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
        birthday: "1979-06-21",
        deathday: "",
        gender: "Unknown",
        biography: "Christopher Michael Pratt (born 21 June 1979) is an American actor, known for starring in both television and action films.",
        birthplace: "Virginia, Minnesota, USA",
        knownFor: "Acting",
        credits: [],
        instagramId: "",
        facebookId: "",
        imdbId: "",
        twitterId: ""
    )
    
    @Published var personPopular: [PersonPopularModel] = []
    @Published var personImages: [PersonImageModel] = []
    
    @Published var isFetchingMore = false
    private var canLoadMore = true
    private var currentPage = 1
    
    init(personUseCase: PersonUseCase) {
        self.personUseCase = personUseCase
    }
    
    func getPerson(personId: Int) {
        self.loadingState = true
        personUseCase.getPerson(personId: personId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.loadingState = false
                }
            } receiveValue: { person in
                self.person = person
            }.store(in: &cancellable)
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
    
    func linkBuilder<Content: View>(
        contentId: Int,
        mediaType: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let destinationView = if mediaType == Constants.movieResponseType {
            AnyView(router.makeMovieDetailView(for: contentId))
        } else {
            AnyView(router.makeTvShowDetailView(for: contentId))
        }
        
        return NavigationLink(destination: destinationView) {
            content()
        }
        .buttonStyle(.plain)
    }
    
    func toCreditDetailView<Content: View>(
        creditModelList: [CreditModel],
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeCreditDetailView(creditModelList: creditModelList)) {
            content()
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
        NavigationLink(destination: router.makePersonImageView(personId: personId)) {
            content()
        }
    }
}
