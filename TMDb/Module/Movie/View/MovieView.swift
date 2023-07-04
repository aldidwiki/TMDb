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
        NavigationView {
            ZStack {
                if self.presenter.loadingState {
                    ProgressView("Loading")
                } else {
                    if presenter.movies.isEmpty {
                        EmptyView(emptyTitle: "No Movies Found")
                    } else {
                        List(self.presenter.movies) { movie in
                            self.presenter.linkBuilder(for: movie.id) {
                                MovieItemView(movie: movie)
                            }
                        }
                    }
                }
            }.onAppear {
                if self.presenter.movies.count == 0 {
                    self.presenter.getMovies()
                }
            }
            .navigationTitle("Popular Movies")
        }
        .searchable(text: $presenter.movieQuery, placement: .automatic)
        .onReceive(presenter.$movieQuery.debounce(for: 1, scheduler: RunLoop.main)) { query in
            if !query.isEmpty {
                presenter.searchMovies(query: query)
            } else {
                presenter.getMovies()
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
