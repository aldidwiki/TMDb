//
//  TvShowSeasonView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 12/08/23.
//

import SwiftUI

struct TvShowSeasonView: View {
    var tvShowId: Int
    var tvShowTitle: String
    var tvShowSeasonList: [TvShowSeasonModel]
    @StateObject var tvShowDetailPresenter: TvShowDetailPresenter
    
    var body: some View {
        List(tvShowSeasonList, id: \.id) { tvShowSeason in
            tvShowDetailPresenter.toTvShowEpisodeView(
                tvShowId: tvShowId,
                seasonNumber: tvShowSeason.seasonNumber,
                seasonName: tvShowSeason.seasonName) {
                    TvShowSeasonItemView(seasonModel: tvShowSeason)
                }
        }
        .listStyle(.plain)
        .navigationTitle("\(tvShowTitle) \(tvShowSeasonList.count > 1 ? "Seasons" : "Season")")
    }
}

struct TvShowSeasonView_Previews: PreviewProvider {
    static var previews: some View {
        let tvShowUseCase: TvShowUseCase = Injection.init().provideTvShowUseCase()
        let favoriteUseCase: FavoriteUseCase = Injection.init().provideFavoriteUseCase()
        
        TvShowSeasonView(
            tvShowId: 123,
            tvShowTitle: "Game of Thrones",
            tvShowSeasonList: [
                TvShowSeasonModel(
                    id: 60523,
                    posterPath: "/A3H6pewHfoy2bXmNhvycOe0xzlC.jpg",
                    seasonName: "Season 1",
                    releaseYear: "2016-10-24",
                    episodeCount: 23,
                    seasonOverview: "When an unexpected accident at the S.T.A.R. Labs Particle Accelerator facility strikes Barry, he finds himself suddenly charged with the incredible power to move at super speeds. While Barry has always been a hero in his soul, his newfound powers have finally given him the ability to act like one. With the help of the research team at S.T.A.R. Labs, Barry begins testing the limits of his evolving powers and using them to stop crime. With a winning personality and a smile on his face, Barry Allen — aka The Flash — is finally moving forward in life … very, very fast!",
                    seasonNumber: 1
                ),
                TvShowSeasonModel(
                    id: 60523,
                    posterPath: "/A3H6pewHfoy2bXmNhvycOe0xzlC.jpg",
                    seasonName: "Season 1",
                    releaseYear: "2016-10-24",
                    episodeCount: 23,
                    seasonOverview: "When an unexpected accident at the S.T.A.R. Labs Particle Accelerator facility strikes Barry, he finds himself suddenly charged with the incredible power to move at super speeds. While Barry has always been a hero in his soul, his newfound powers have finally given him the ability to act like one. With the help of the research team at S.T.A.R. Labs, Barry begins testing the limits of his evolving powers and using them to stop crime. With a winning personality and a smile on his face, Barry Allen — aka The Flash — is finally moving forward in life … very, very fast!",
                    seasonNumber: 1
                ),
                TvShowSeasonModel(
                    id: 60523,
                    posterPath: "/A3H6pewHfoy2bXmNhvycOe0xzlC.jpg",
                    seasonName: "Season 1",
                    releaseYear: "2016-10-24",
                    episodeCount: 23,
                    seasonOverview: "When an unexpected accident at the S.T.A.R. Labs Particle Accelerator facility strikes Barry, he finds himself suddenly charged with the incredible power to move at super speeds. While Barry has always been a hero in his soul, his newfound powers have finally given him the ability to act like one. With the help of the research team at S.T.A.R. Labs, Barry begins testing the limits of his evolving powers and using them to stop crime. With a winning personality and a smile on his face, Barry Allen — aka The Flash — is finally moving forward in life … very, very fast!",
                    seasonNumber: 1
                )
            ],
            tvShowDetailPresenter: TvShowDetailPresenter(
                tvShowUseCase: tvShowUseCase,
                favoriteUseCase: favoriteUseCase)
        )
    }
}
