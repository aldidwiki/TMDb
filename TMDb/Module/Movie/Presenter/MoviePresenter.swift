//
//  MoviePresenter.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import Combine

class MoviePresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let router = MovieRouter()
    private let movieUseCase: MovieUseCase
    
    @Published var movies: [MovieModel] = []
    @Published var errorMessage = ""
    @Published var loadingState = true
    
    @Published var isFetchingMore = false
    private var currentPage = 1
    private var canLoadMore = true
    
    init(movieUseCase: MovieUseCase) {
        self.movieUseCase = movieUseCase
    }
    
    func getMovies(reset: Bool = false) {
        if reset {
            currentPage = 1
            canLoadMore = true
            loadingState = true
        }
        
        guard canLoadMore && !isFetchingMore else { return }
        
        if currentPage > 1 {
            isFetchingMore = true
        }
        
        movieUseCase.getMovies(page: currentPage)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.isFetchingMore = false
                }
            } receiveValue: { newMovies in
                if newMovies.isEmpty {
                    self.canLoadMore = false
                } else {
                    if reset {
                        self.movies = newMovies
                    } else {
                        self.isFetchingMore = false
                        self.movies.append(contentsOf: newMovies)
                    }
                    
                    if self.currentPage == 1 {
                        self.loadingState = false
                    }
                    
                    self.currentPage += 1
                }
            }.store(in: &cancellable)
    }
    
    func searchMovies(reset: Bool = false, query: String) {
        if reset {
            currentPage = 1
            canLoadMore = true
            loadingState = true
        }
        
        guard canLoadMore && !isFetchingMore else { return }
        
        if currentPage > 1 {
            isFetchingMore = true
        }
        
        movieUseCase.searchMovies(query: query, page: currentPage)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.isFetchingMore = false
                }
            } receiveValue: { newMovies in
                if newMovies.isEmpty {
                    self.canLoadMore = false
                } else {
                    if self.currentPage == 1 {
                        self.movies = newMovies
                        self.loadingState = false
                    } else {
                        self.isFetchingMore = false
                        self.movies.append(contentsOf: newMovies)
                    }
                    
                    self.currentPage += 1
                }
            }.store(in: &cancellable)
    }
    
    func linkBuilder<Content: View>(
        for movieId: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: router.makeDetailView(for: movieId)) {
            content()
        }
        .buttonStyle(.plain)
    }
}
