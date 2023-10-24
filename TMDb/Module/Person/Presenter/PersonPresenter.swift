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
    
    init(personUseCase: PersonUseCase) {
        self.personUseCase = personUseCase
    }
    
    func getPerson(personId: Int) {
        self.loadingState = true
        personUseCase.getPerson(personId: personId)
            .receive(on: RunLoop.main)
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
    
    func getPopularPerson() {
        self.loadingState = true
        personUseCase.getPopularPerson()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { popularPerson in
                self.personPopular = popularPerson
            }.store(in: &cancellable)
    }
    
    func linkBuilder<Content: View>(
        movieId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeMovieDetailView(for: movieId)) {
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
}
