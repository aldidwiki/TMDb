//
//  MovieView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct MovieView: View {
    @ObservedObject var presenter: MoviePresenter
    @State var movieQuery: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if self.presenter.loadingState {
                    ProgressView("Loading")
                } else {
                    if presenter.movies.isEmpty {
                        EmptyView(emptyTitle: "No Movies Found")
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(self.presenter.movies) { movie in
                                    self.presenter.linkBuilder(for: movie.id) {
                                        MovieItemView(movie: movie)
                                    }
                                    .onAppear {
                                        if movie == self.presenter.movies.last {
                                            if self.movieQuery.isEmpty {
                                                presenter.getMovies()
                                            } else {
                                                presenter.searchMovies(query: self.movieQuery)
                                            }
                                        }
                                    }
                                    
                                    if movie == presenter.movies.last && presenter.isFetchingMore {
                                        let _ = print(movie)
                                        let _ = print(presenter.movies.last)
                                        let _ = print(presenter.isFetchingMore)
                                    
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .scrollTargetLayout()
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                if self.presenter.movies.count == 0 {
                    self.presenter.getMovies(reset: true)
                }
            }
            .navigationTitle("Popular Movies")
        }
        .searchable(text: $movieQuery, placement: .automatic, prompt: "Search Movies")
        .onChange(of: movieQuery) { _, query in
            if !query.isEmpty {
                presenter.searchMovies(reset: true, query: query)
            } else {
                presenter.getMovies(reset: true)
            }
        }
    }
}

struct MovieView_Previews: PreviewProvider {
    static var previews: some View {
        let movieUseCase = Injection.init().provideMovieUseCase()
        MovieView(presenter: MoviePresenter(movieUseCase: movieUseCase))
    }
}
