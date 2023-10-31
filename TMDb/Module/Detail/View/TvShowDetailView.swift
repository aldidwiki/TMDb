//
//  TvShowDetailView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TvShowDetailView: View {
    @ObservedObject var presenter: TvShowDetailPresenter
    @State var showSheet = false
    @State var isFavorite = false
    var tvShowId: Int
    
    var body: some View {
        ZStack {
            if presenter.loadingState {
                ProgressView("Loading")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        if !presenter.tvShow.backdropPath.isEmpty {
                            tvBackdrop
                        }
                        
                        tvContentDetail
                            .padding([.top, .horizontal])
                        
                        tvContentUtils
                        
                        tvOverview
                        
                        if !presenter.tvShow.credits.isEmpty {
                            tvCredits
                        }
                        
                        tvDetailInfo
                        
                        ExternalMediaView(
                            instagramId: presenter.tvShow.instagramId,
                            facebookId: presenter.tvShow.facebookId,
                            twitterId: presenter.tvShow.twitterId,
                            imdbId: presenter.tvShow.imdbId
                        )
                        .padding(.vertical)
                    }
                }
                .blur(radius: showSheet ? 10 : 0)
                .animation(.spring(), value: showSheet)
            }
        }.onAppear {
            presenter.getTvShow(tvShowId: tvShowId)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(presenter.tvShow.title)
        .toolbar {
            ToolbarItem {
                Button {
                    if !presenter.isFavorite {
                        self.presenter.addFavorite(tvShowDetailModel: self.presenter.tvShow)
                    } else {
                        self.presenter.deleteFavorite(tvShowId: self.presenter.tvShow.id)
                    }
                } label: {
                    Image(systemName: self.presenter.isFavorite ? "heart.fill" : "heart")
                        .contentTransition(.symbolEffect(.replace))
                }
                .disabled(self.presenter.loadingState)
            }
        }
    }
}

extension TvShowDetailView {
    var tvPoster: some View {
        WebImage(url: URL(string: API.imageBaseUrl + presenter.tvShow.posterPath))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(height: 175)
    }
    
    var tvBackdrop: some View {
        WebImage(url: URL(string: API.backdropBaseUrl + presenter.tvShow.backdropPath))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
    }
    
    var tvContentDetail: some View {
        HStack {
            tvPoster
            
            VStack {
                Text(presenter.tvShow.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(presenter.tvShow.releaseDate.formatDateString())
                    .multilineTextAlignment(.center)
                
                HStack {
                    if presenter.tvShow.runtime != 0 {
                        Text(presenter.tvShow.runtime.formatRuntime())
                            .multilineTextAlignment(.center)
                        Text("\u{2022}")
                    }
                    
                    Text(presenter.tvShow.contentRating)
                        .multilineTextAlignment(.center)
                }
                
                Text(presenter.tvShow.genre)
                    .multilineTextAlignment(.center)
                    .padding(.top, 1)
                
                if !presenter.tvShow.tagline.isEmpty {
                    Text(presenter.tvShow.tagline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .italic()
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal)
        }
    }
    
    var tvOverview: some View {
        VStack(alignment: .leading) {
            Text("Overview")
                .padding([.top, .horizontal])
                .padding(.bottom, 1)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(presenter.tvShow.overview)
                .padding(.horizontal)
        }
    }
    
    var tvContentUtils: some View {
        HStack(alignment: .center) {
            Spacer()
            ZStack {
                CircularProgressView(progress: presenter.tvShow.rating / 10, lineWidth: 3)
                    .frame(width: 35, height: 35)
                
                Text((presenter.tvShow.rating / 10).toPercentage())
                    .font(.system(size: 11))
            }
            
            Text("User Score")
            
            if presenter.tvShow.videos.count > 1 {
                Text("\u{FF5C}")
                    .fontWeight(.medium)
                    .padding(.horizontal)
                
                tvTrailerBottomSheet
            } else {
                if let firstKey = presenter.tvShow.videos.first?.key {
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
    
    var tvTrailerBottomSheet: some View {
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
                
                List(presenter.tvShow.videos, id: \.id) { video in
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
    
    var tvCredits: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Top Billed Cast")
                    .padding(.horizontal)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                presenter.toCreditDetailView(for: presenter.tvShow.credits) {
                    Text("FULL CAST")
                        .padding(.horizontal)
                        .font(.subheadline)
                }
            }
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: 20) {
                    ForEach(presenter.tvShow.credits.take(length: 10), id: \.id) { cast in
                        presenter.toPersonView(for: cast.id) {
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
    
    var tvDetailInfo: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Details")
                    .padding(.horizontal)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                presenter.toTvShowSeasonView(for: presenter.tvShow.seasons, title: presenter.tvShow.title, id: presenter.tvShow.id) {
                    Text("SEE SEASONS")
                        .padding(.horizontal)
                        .font(.subheadline)
                }
                
            }
            .padding(.bottom, 2)
            
            HStack(alignment: .top) {
                VStack {
                    Text("Status")
                    Text(presenter.tvShow.status)
                        .fontWeight(.thin)
                }
                .frame(maxWidth: 200)
                
                VStack {
                    Text("Spoken Language")
                    Text(presenter.tvShow.spokenLanguage)
                        .multilineTextAlignment(.center)
                        .fontWeight(.thin)
                }
                .frame(maxWidth: 200)
            }
            
            Spacer()
            
            HStack(alignment: .top) {
                VStack {
                    Text("Network")
                    ForEach(presenter.tvShow.networks) { network in
                        WebImage(url: URL(string: API.logoImageBaseUrl + network.logoPath))
                            .resizable()
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(width: 15, height: 15)
                    }
                }
                .frame(maxWidth: 200)
                
                VStack {
                    Text("Type")
                    Text(presenter.tvShow.type)
                        .fontWeight(.thin)
                }
                .frame(maxWidth: 200)
            }
        }
        .padding(.top)
        .padding(.bottom)
    }
}

struct TvShowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase = Injection.init().provideFavoriteUseCase()
        TvShowDetailView(
            presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase, favoriteUseCase: favoriteUseCase),
            tvShowId: 114472
        )
    }
}
