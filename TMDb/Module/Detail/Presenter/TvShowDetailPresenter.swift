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
        id: 114472,
        backdropPath: "",
        releaseDate: "",
        title: "",
        overview: "",
        posterPath: "",
        tagline: "",
        status: "",
        type: "",
        genre: "",
        rating: 0.0,
        runtime: 0,
        spokenLanguage: ""
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
