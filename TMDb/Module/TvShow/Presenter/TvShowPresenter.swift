//
//  TvShowPresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import Foundation
import Combine
import SwiftUI

class TvShowPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    private let router = TvShowRouter()
    
    private let tvShowUseCase: TvShowUseCase
    
    @Published var tvShows: [TvShowModel] = []
    @Published var errorMessage = ""
    @Published var loadingState = false
    
    @Published var tvQuery = ""
    
    init(tvShowUseCase: TvShowUseCase) {
        self.tvShowUseCase = tvShowUseCase
    }
    
    func getTvShows() {
        loadingState = true
        tvShowUseCase.getTvShows()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { tvShows in
                self.tvShows = tvShows
            }.store(in: &cancellable)
    }
    
    func searchTvShows(query: String) {
        loadingState = true
        tvShowUseCase.searchTvShows(query: query)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { tvShows in
                self.tvShows = tvShows
            }.store(in: &cancellable)
        
    }
    
    func toTvShowDetailView<Content: View>(
        for tvShowId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeTvShowDetailView(for: tvShowId)) {
            content()
        }
    }
}
