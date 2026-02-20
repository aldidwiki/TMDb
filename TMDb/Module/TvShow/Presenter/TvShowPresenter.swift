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
    @Published var loadingState = true
    
    @Published var isFetchingMore = false
    private var canLoadMore = true
    private var currentPage = 1
    
    init(tvShowUseCase: TvShowUseCase) {
        self.tvShowUseCase = tvShowUseCase
    }
    
    func getTvShows(reset: Bool = false) {
        if reset {
            currentPage = 1
            canLoadMore = true
            loadingState = true
            tvShows.removeAll()
        }
        
        guard canLoadMore && !isFetchingMore else { return }
        
        if currentPage > 1 {
            isFetchingMore = true
        }
        
        tvShowUseCase.getTvShows(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.isFetchingMore = false
                }
            } receiveValue: { newTvShows in
                let uniqueTvShows = newTvShows.filter({ newMovie in
                    !self.tvShows.contains { $0.id == newMovie.id }
                })
                
                if uniqueTvShows.isEmpty {
                    self.canLoadMore = false
                    
                    if self.currentPage == 1 {
                        self.loadingState = false
                        self.tvShows = newTvShows
                    }
                } else {
                    if reset {
                        self.tvShows = uniqueTvShows
                    } else {
                        self.tvShows.append(contentsOf: uniqueTvShows)
                    }
                    
                    if self.currentPage == 1 {
                        self.loadingState = false
                    }
                    
                    self.currentPage += 1
                } 
            }.store(in: &cancellable)
    }
    
    func toTvShowDetailView<Content: View>(
        for tvShowId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeTvShowDetailView(for: tvShowId)) {
            content()
        }
        .buttonStyle(.plain)
    }
}
