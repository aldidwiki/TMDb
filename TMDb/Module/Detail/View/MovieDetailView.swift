//
//  DetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct MovieDetailView: View {
    @StateObject var presenter: MovieDetailPresenter
    @State var showSheet = false
    
    var movieId: Int
    
    var body: some View {
        ZStack {
            if presenter.loadingState {
                ProgressView("Loading")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        if !presenter.movie.backdropPath.isEmpty {
                            presenter.toMovieImageGallery(for: movieId) {
                                movieBackdrop
                            }
                        }
                        
                        movieContentDetail
                            .padding([.top, .horizontal])
                        
                        movieContentUtils
                        
                        movieOverview
                        
                        if !presenter.movie.cast.isEmpty {
                            movieCredits
                        }
                        
                        movieDetailInfo
                        
                        ExternalMediaView(
                            instagramId: presenter.movie.instagramId,
                            facebookId: presenter.movie.facebookId,
                            twitterId: presenter.movie.twitterId,
                            imdbId: presenter.movie.imdbId
                        )
                        .padding(.vertical)
                    }
                }
                .blur(radius: showSheet ? 10 : 0)
                .animation(.spring(), value: showSheet)
            }
        }.onAppear {
            presenter.getMovie(movieId: movieId)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(presenter.movie.title)
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
                        .contentTransition(.symbolEffect(.replace))
                }.disabled(self.presenter.loadingState)
            }
        }
    }
}

extension MovieDetailView {
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
                
                presenter.toCreditDetailView(for: presenter.movie.cast) {
                    Text("FULL CAST")
                        .padding(.horizontal)
                        .font(.subheadline)
                }
            }
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    ForEach(presenter.movie.cast.take(length: 10), id: \.id) { cast in
                        presenter.toPersonDetail(for: cast.id) {
                            CreditItemView(creditModel: cast, isPersonView: false)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
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
                        .multilineTextAlignment(.center)
                    
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
    
    var movieContentUtils: some View {
        HStack(alignment: .center) {
            Spacer()
            ZStack {
                CircularProgressView(progress: presenter.movie.rating / 10, lineWidth: 3)
                    .frame(width: 35, height: 35)
                
                Text((presenter.movie.rating / 10).toPercentage())
                    .font(.system(size: 11))
            }
            
            Text("User Score")
            
            if presenter.movie.videos.count > 1 {
                Text("\u{FF5C}")
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                movieTrailerBottomSheet
            } else {
                if let firstKey = presenter.movie.videos.first?.key {
                    Text("\u{FF5C}")
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    
                    Link(destination: URL(string: Constants.youtubeBaseUrl + firstKey)!) {
                        Label("Play Trailer", systemImage: "play.fill")
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
        }
        .padding(.top)
    }
    
    var movieTrailerBottomSheet: some View {
        Button {
            showSheet.toggle()
        } label: {
            Label("Play Trailer", systemImage: "play.fill")
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            VStack(alignment: .leading) {
                Text("Choose Trailer")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.leading, 20)
                    .padding(.top)
                
                List(presenter.movie.videos, id: \.id) { video in
                    Link(video.name, destination: URL(string: Constants.youtubeBaseUrl + video.key)!)
                        .buttonStyle(.plain)
                        .padding(.vertical, 1)
                }
                .listStyle(.plain)
                .presentationDetents([.height(300), .medium])
            }
            .padding(.vertical)
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let detailUseCase = Injection.init().provideDetailUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        MovieDetailView(
            presenter: MovieDetailPresenter(detailUseCase: detailUseCase, favoriteUseCase: favoriteUseCase),
            movieId: 436270
        )
    }
}
