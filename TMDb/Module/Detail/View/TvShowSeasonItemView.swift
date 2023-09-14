//
//  TvShowSeasonItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 12/08/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TvShowSeasonItemView: View {
    var seasonModel: TvShowSeasonModel
    
    var body: some View {
        HStack(alignment: .top) {
            tvSeasonPoster
            
            VStack(alignment: .leading) {
                Text(seasonModel.seasonName)
                    .lineLimit(1)
                    .fontWeight(.bold)
                    .font(.title3)
                
                Text("\(seasonModel.releaseYear.formatDateString(input: "YYYY-MM-DD", output: "YYYY")) \u{2022} \(seasonModel.episodeCount) episodes")
                
                ExpandableTextView(textData: seasonModel.seasonOverview)
                    .padding(.top, 2)
                    .font(.system(size: 16))
                    .fontWeight(.light)
            }
            .padding(.leading, 4)
        }
        .padding(.vertical)
    }
}

extension TvShowSeasonItemView {
    var tvSeasonPoster: some View {
        WebImage(url: URL(string: API.imageBaseUrl + seasonModel.posterPath))
            .resizable()
            .placeholder(content: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .frame(width: 100, height: 150)
            .cornerRadius(6)
    }
}

struct TvShowSeasonItemView_Previews: PreviewProvider {
    static var previews: some View {
        TvShowSeasonItemView(seasonModel: TvShowSeasonModel(
            id: 60523,
            posterPath: "/A3H6pewHfoy2bXmNhvycOe0xzlC.jpg",
            seasonName: "Season 1",
            releaseYear: "2016-10-24",
            episodeCount: 23,
            seasonOverview: "When an unexpected accident at the S.T.A.R. Labs Particle Accelerator facility strikes Barry, he finds himself suddenly charged with the incredible power to move at super speeds. While Barry has always been a hero in his soul, his newfound powers have finally given him the ability to act like one. With the help of the research team at S.T.A.R. Labs, Barry begins testing the limits of his evolving powers and using them to stop crime. With a winning personality and a smile on his face, Barry Allen — aka The Flash — is finally moving forward in life … very, very fast!", seasonNumber: 123
        ))
    }
}
