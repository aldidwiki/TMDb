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
                        
                        //                        movieContentUtils
                        
                        tvOverview
                        
                        //                        if !presenter.tvShow.cast.isEmpty {
                        //                            movieCredits
                        //                        }
                        
                        //                        movieDetailInfo
                        //
                        //                        ExternalMediaView(
                        //                            instagramId: presenter.movie.instagramId,
                        //                            facebookId: presenter.movie.facebookId,
                        //                            twitterId: presenter.movie.twitterId,
                        //                            imdbId: presenter.movie.imdbId
                        //                        )
                            .padding(.vertical)
                    }
                }
            }
        }.onAppear {
            presenter.getTvShow(tvShowId: tvShowId)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(presenter.tvShow.title)
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
                    }
                    //
                    //                    if !presenter.movie.certification.isEmpty {
                    //                        Text("\u{2022}")
                    //                        Text(presenter.movie.certification)
                    //                            .multilineTextAlignment(.center)
                    //                    }
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
}

struct TvShowDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let tvShowUseCase = Injection.init().provideTvShowUseCase()
        TvShowDetailView(
            presenter: TvShowDetailPresenter(tvShowUseCase: tvShowUseCase),
            tvShowId: 114472
        )
    }
}
