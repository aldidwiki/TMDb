//
//  ExternalMediaView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import SwiftUI

struct ExternalMediaView: View {
    var instagramId: String
    var facebookId: String
    var twitterId: String
    var imdbId: String
    
    var body: some View {
        HStack(spacing: 30) {
            Spacer()
            if !facebookId.isEmpty {
                Link(destination: URL(string: "https://www.facebook.com/" + facebookId)!) {
                    Image("facebook_logo")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            
            if !instagramId.isEmpty {
                Link(destination: URL(string: "https://www.instagram.com/" + instagramId)!) {
                    Image("instagram_logo")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            
            if !imdbId.isEmpty {
                Link(destination: URL(string: "https://www.imdb.com/title/" + imdbId)!) {
                    Image("imdb_logo")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            
            if !twitterId.isEmpty {
                Link(destination: URL(string: "https://twitter.com/" + twitterId)!) {
                    Image("twitter_logo")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            Spacer()
        }
    }
}

struct ExternalMediaView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalMediaView(
            instagramId: "prattprattpratt",
            facebookId: "PrattPrattPratt",
            twitterId: "prattprattpratt",
            imdbId: "nm0695435"
        )
    }
}
