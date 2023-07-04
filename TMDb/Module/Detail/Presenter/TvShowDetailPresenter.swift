//
//  TvShowDetailPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation
import Combine
import SwiftUI

class TvShowDetailPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let tvShowUseCase: TvShowUseCase
    
    @Published var errorMessage = ""
    @Published var loadingState = false
    @Published var tvShow = TvShowDetailModel(
        id: 436270,
        backdropPath: "",
        releaseDate: "2022-12-22",
        title: "/bQXAqRx2Fgc46uCVWgoPz5L5Dtr.jpg",
        overview: "Nearly 5,000 years after he was bestowed with the almighty powers of the Egyptian gods—and imprisoned just as quickly—Black Adam is freed from his earthly tomb, ready to unleash his unique form of justice on the modern world.",
        posterPath: "The world needed a hero. It got Black Adam.",
        tagline: "2022-10-19",
        status: "/3CxUndGhUcZdt1Zggjdb2HkLLQX.jpg",
        type: "Miniseries",
        genre: "Action",
        rating: 7.1,
        runtime: 55,
        spokenLanguage: "English"
    )
    
    init(tvShowUseCase: TvShowUseCase) {
        self.tvShowUseCase = tvShowUseCase
    }
    
    func getTvShow(tvShowId: Int) {
        self.loadingState = true
        tvShowUseCase.getTvShow(tvShowId: tvShowId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { tvShow in
                self.tvShow = tvShow
            }.store(in: &cancellable)
    }
}
