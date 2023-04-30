//
//  DetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    @ObservedObject var presenter: DetailPresenter
    
    var body: some View {
        ZStack {
            if presenter.loadingState {
                ProgressView("Loading")
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        movieBackdrop
                        
                        movieDetail
                            .padding([.top, .horizontal])
                        
                        Text("Overview")
                            .padding([.top, .horizontal])
                            .font(.title2)
                            .bold()
                        
                        Text(presenter.movie.overview)
                            .padding(.horizontal)
                    }
                }
            }
        }.onAppear {
            presenter.getMovie()
        }.toolbar {
            ToolbarItem {
                Button {
                    if !presenter.isFavorite {
                        self.presenter.addFavorite(movie: self.presenter.movie)
                    } else {
                        self.presenter.deleteFavorite(movieId: self.presenter.movie.id)
                    }
                } label: {
                    Image(systemName: self.presenter.isFavorite ? "heart.fill" : "heart")
                }.disabled(self.presenter.loadingState)
            }
        }
    }
}

extension DetailView {
    var moviePoster: some View {
        WebImage(url: URL(string: API.imageBaseUrl + (presenter.movie.posterPath ?? "")))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(height: 175)
    }
    
    var movieBackdrop: some View {
        WebImage(url: URL(string: API.backdropBaseUrl + (presenter.movie.backdropPath ?? "")))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
    }
    
    var movieDetail: some View {
        HStack {
            moviePoster
            
            VStack {
                Text(presenter.movie.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(
                    presenter.movie.releaseDate.formatDateString()
                )
                
                if !presenter.movie.tagline.isEmpty {
                    Text(presenter.movie.tagline)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.top)
                }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let detailUseCase = Injection.init().provideDetailUseCase(movieId: 436270)
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        DetailView(presenter: DetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
    }
}
