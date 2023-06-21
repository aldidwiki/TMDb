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
    
    var isPerson = false
    
    var body: some View {
        HStack(spacing: 30) {
            Spacer()
            if !facebookId.isEmpty {
                Link(destination: URL(string: Constants.facebookBaseUrl + facebookId)!) {
                    Image("facebook_logo")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            
            if !instagramId.isEmpty {
                Link(destination: URL(string: Constants.instagramBaseUrl + instagramId)!) {
                    Image("instagram_logo")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            
            if !imdbId.isEmpty {
                Link(destination: URL(string: isPerson ? Constants.imdbPersonBaseUrl + imdbId : Constants.imdbBaseUrl + imdbId)!) {
                    Image("imdb_logo")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            
            if !twitterId.isEmpty {
                Link(destination: URL(string: Constants.twitterBaseUrl + twitterId)!) {
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
