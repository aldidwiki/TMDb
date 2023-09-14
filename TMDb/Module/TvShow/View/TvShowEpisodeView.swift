//
//  TvShowEpisodeView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import SwiftUI

struct TvShowEpisodeView: View {
    var tvShowEpisodes: [TvShowSeasonDetailModel]
    
    var body: some View {
        List(tvShowEpisodes) { episode in
            TvShowEpisodeItemView(episodeModel: episode)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

struct TvShowEpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        TvShowEpisodeView(tvShowEpisodes: [
            TvShowSeasonDetailModel(
                id: 973190,
                name: "Two Swords",
                overview: "Tyrion welcomes a guest to King’s Landing. At Castle Black, Jon Snow finds himself unwelcome. Dany is pointed to Meereen, the mother of all slave cities. Arya runs into an old friend.",
                runtime: 59,
                rating: 8,
                episodeNumber: 1,
                stillPath: "/mA7XXz9qHjsXqXHDDyFKPm4SOTv.jpg",
                airDate: "2014-04-06"
            ),
            TvShowSeasonDetailModel(
                id: 973190,
                name: "Two Swords",
                overview: "Tyrion welcomes a guest to King’s Landing. At Castle Black, Jon Snow finds himself unwelcome. Dany is pointed to Meereen, the mother of all slave cities. Arya runs into an old friend.",
                runtime: 59,
                rating: 8,
                episodeNumber: 1,
                stillPath: "/mA7XXz9qHjsXqXHDDyFKPm4SOTv.jpg",
                airDate: "2014-04-06"
            ),
            TvShowSeasonDetailModel(
                id: 973190,
                name: "Two Swords",
                overview: "Tyrion welcomes a guest to King’s Landing. At Castle Black, Jon Snow finds himself unwelcome. Dany is pointed to Meereen, the mother of all slave cities. Arya runs into an old friend.",
                runtime: 59,
                rating: 8,
                episodeNumber: 1,
                stillPath: "/mA7XXz9qHjsXqXHDDyFKPm4SOTv.jpg",
                airDate: "2014-04-06"
            ),
            TvShowSeasonDetailModel(
                id: 973190,
                name: "Two Swords",
                overview: "Tyrion welcomes a guest to King’s Landing. At Castle Black, Jon Snow finds himself unwelcome. Dany is pointed to Meereen, the mother of all slave cities. Arya runs into an old friend.",
                runtime: 59,
                rating: 8,
                episodeNumber: 1,
                stillPath: "/mA7XXz9qHjsXqXHDDyFKPm4SOTv.jpg",
                airDate: "2014-04-06"
            )
        ])
    }
}
