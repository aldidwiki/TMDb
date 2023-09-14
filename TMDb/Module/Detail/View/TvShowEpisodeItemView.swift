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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color("card_color"))
                .shadow(radius: 4)
            
            VStack(alignment: .leading) {
                HStack {
                    episodePoster
                    
                    VStack(alignment: .leading) {
                        Text("\(episodeModel.episodeNumber)  \(episodeModel.name)")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .lineLimit(2)
                        
                        HStack {
                            Text(episodeModel.airDate.formatDateString())
                                .font(.system(size: 12))
                                .fontWeight(.light)
                            
                            Text("\u{2022}")
                                .fontWeight(.light)
                            
                            Text(episodeModel.runtime.formatRuntime())
                                .font(.system(size: 12))
                                .fontWeight(.light)
                        }
                        
                        ContentRatingView(contentRating: episodeModel.rating)
                    }
                    
                    Spacer()
                }
                
                Text(episodeModel.overview)
                    .font(.system(size: 14))
                    .padding(.top, 4)
                    .padding(.horizontal, 6)
                
                Spacer()
            }
        }
        .padding(.vertical, 8)
    }
}

extension TvShowEpisodeItemView {
    var episodePoster: some View {
        WebImage(url: URL(string: API.episodeStillBaseUrl + episodeModel.stillPath))
            .resizable()
            .placeholder(content: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .cornerRadius(6)
            .frame(width: 160, height: 90)
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
