//
//  HomePresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import Combine

class HomePresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = HomeRouter()
    private let homeUseCase: HomeUseCase
    
    @Published var movies: [MovieModel] = []
    @Published var errorMessage = ""
    @Published var loadingState = false
    
    @Published var movieQuery = ""
    
    init(homeUseCase: HomeUseCase) {
        self.homeUseCase = homeUseCase
    }
    
    func getMovies() {
        loadingState = true
        homeUseCase.getMovies()
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { movies in
                self.movies = movies
            }.store(in: &cancellable)
    }
    
    func searchMovies(query: String) {
        loadingState = true
        homeUseCase.searchMovies(query: query)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                    case .failure:
                        self.errorMessage = String(describing: completion)
                    case .finished:
                        self.loadingState = false
                }
            } receiveValue: { movies in
                self.movies = movies
            }.store(in: &cancellable)
    }
    
    func linkBuilder<Content: View>(
        for movieId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeDetailView(for: movieId)) {
            content()
        }
    }
}
