//
//  TvShowEpisodeItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TvShowEpisodeItemView: View {
    var episodeModel: TvShowSeasonDetailModel
    private let radiusValue: CGFloat = 6
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            episodePoster
                .clipShape(
                    .rect(
                        topLeadingRadius: radiusValue,
                        topTrailingRadius: radiusValue
                    )
                )
            
            Text("\(episodeModel.episodeNumber)  \(episodeModel.name)")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .lineLimit(2)
                .padding(.horizontal)
                .padding(.top)
           
            HStack {
                ContentRatingView(contentRating: episodeModel.rating)
                
                Text(episodeModel.airDate.formatDateString())
                    .font(.system(size: 12))
                    .fontWeight(.light)
                
                Text("\u{2022}")
                    .fontWeight(.light)
                
                Text(episodeModel.runtime.formatRuntime())
                    .font(.system(size: 12))
                    .fontWeight(.light)
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            Text(episodeModel.overview)
                .font(.system(size: 14))
                .padding(.horizontal)
                .padding(.top, 8)
        }
        .padding(.bottom)
        .background {
            RoundedRectangle(cornerRadius: radiusValue, style: .continuous)
                .fill(Color("card_color"))
                .shadow(color: .black.opacity(0.3), radius: radiusValue)
        }
    }
}

extension TvShowEpisodeItemView {
    var episodePoster: some View {
        WebImage(
            url: URL(string: API.episodeStillBaseUrl + episodeModel.stillPath)
        )
        .resizable()
        .placeholder(content: {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
        })
        .indicator(.activity)
        .scaledToFill()
        .transition(.fade(duration: 0.5))
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipped()
    }
}

struct TvShowEpisodeItemView_Previews: PreviewProvider {
    static var previews: some View {
        TvShowEpisodeItemView(episodeModel: TvShowSeasonDetailModel(
            id: 973190,
            name: "Two Sword",
            overview: "Tyrion welcomes a guest to King’s Landing. At Castle Black, Jon Snow finds himself unwelcome. Dany is pointed to Meereen, the mother of all slave cities. Arya runs into an old friend.",
            runtime: 59,
            rating: 8,
            episodeNumber: 1,
            stillPath: "/mA7XXz9qHjsXqXHDDyFKPm4SOTv.jpg",
            airDate: "2014-04-06"
        ))
    }
}
