//
//  PersonPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation
import Combine

class PersonPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let personUseCase: PersonUseCase
    
    @Published var errorMessage = ""
    @Published var loadingState = false
    @Published var isFavorite = false
    @Published var person = PersonModel(
        id: 73457,
        name: "Chris Pratt",
        profilePath: "/83o3koL82jt30EJ0rz4Bnzrt2dd.jpg",
        birthday: "1979-06-21",
        deathday: "",
        gender: "Unknown",
        biography: "Christopher Michael Pratt (born 21 June 1979) is an American actor, known for starring in both television and action films.",
        birthplace: "Virginia, Minnesota, USA",
        knownFor: "Acting",
        credits: []
    )
    
    init(personUseCase: PersonUseCase) {
        self.personUseCase = personUseCase
    }
    
    func getPerson() {
        self.loadingState = true
        personUseCase.getPerson()
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
}
