//
//  MovieView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct MovieView: View {
    @ObservedObject var presenter: MoviePresenter
    
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
                                        VStack {
                                            MovieItemView(movie: movie)
                                            
                                            if movie != self.presenter.movies.last {
                                                NativeDivider()
                                            }
                                        }
                                    }
                                    .onAppear {
                                        if movie == self.presenter.movies.last {
                                            presenter.getMovies()
                                        }
                                    }
                                }
                                
                                if presenter.isFetchingMore {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                }
                            }
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
    }
}

struct MovieView_Previews: PreviewProvider {
    static var previews: some View {
        let movieUseCase = Injection.init().provideMovieUseCase()
        MovieView(presenter: MoviePresenter(movieUseCase: movieUseCase))
    }
}
