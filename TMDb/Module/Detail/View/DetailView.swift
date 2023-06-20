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
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        if !presenter.movie.backdropPath.isEmpty {
                            movieBackdrop
                        }
                        
                        movieContentDetail
                            .padding([.top, .horizontal])
                        
                        movieOverview
                        
                        if !presenter.movie.cast.isEmpty {
                            movieCredits
                        }
                        
                        movieDetailInfo
                    }
                }
            }
        }.onAppear {
            presenter.getMovie()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        WebImage(url: URL(string: API.imageBaseUrl + presenter.movie.posterPath))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(height: 175)
    }
    
    var movieBackdrop: some View {
        WebImage(url: URL(string: API.backdropBaseUrl + presenter.movie.backdropPath))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
    }
    
    var movieContentDetail: some View {
        HStack {
            moviePoster
            
            VStack {
                Text(presenter.movie.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(presenter.movie.releaseDate.formatDateString())
                    .multilineTextAlignment(.center)
                
                HStack {
                    if presenter.movie.runtime != 0 {
                        Text(presenter.movie.runtime.formatRuntime())
                            .multilineTextAlignment(.center)
                    }
                    
                    if !presenter.movie.certification.isEmpty {
                        Text("\u{2022}")
                        Text(presenter.movie.certification)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Text(presenter.movie.genre)
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
                
                if !presenter.movie.tagline.isEmpty {
                    Text(presenter.movie.tagline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal)
        }
    }
    
    var movieOverview: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .padding([.top, .horizontal])
                .padding(.bottom, 1)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(presenter.movie.overview)
                .padding(.horizontal)
        }
    }
    
    var movieCredits: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Top Billed Cast")
                    .padding(.horizontal)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                presenter.toCreditDetailView(for: presenter.movie.cast, presenter: presenter) {
                    Text("FULL CAST")
                        .padding(.horizontal)
                }
            }
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    ForEach(presenter.movie.cast.take(length: 10), id: \.id) { cast in
                        presenter.toPersonDetail(for: cast.id) {
                            CreditItemView(creditModel: cast)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding(.top)
    }
    
    var movieDetailInfo: some View {
        VStack(alignment: .leading) {
            Text("Details")
                .padding([.top, .horizontal])
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Spacer()
                
                VStack {
                    Text("Status")
                    Text(presenter.movie.status)
                        .fontWeight(.thin)
                    
                    Spacer()
                    
                    Text("Budget")
                    Text(presenter.movie.budget.formatCurrency())
                        .fontWeight(.thin)
                }
                
                Spacer()
                
                VStack {
                    Text("Spoken Language")
                    Text(presenter.movie.spokenLanguage)
                        .fontWeight(.thin)
                    
                    Spacer()
                    
                    Text("Revenue")
                    Text(presenter.movie.revenue.formatCurrency())
                        .fontWeight(.thin)
                }
                
                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(.bottom)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let detailUseCase = Injection.init().provideDetailUseCase(movieId: 436270)
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        DetailView(presenter: DetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase))
    }
}
