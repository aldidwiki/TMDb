//
//  Constants.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 21/06/23.
//

import Foundation

class Constants {
    static let instagramBaseUrl = "https://www.instagram.com/"
    static let facebookBaseUrl = "https://www.facebook.com/"
    static let twitterBaseUrl = "https://twitter.com/"
    static let imdbBaseUrl = "https://www.imdb.com/title/"
    static let imdbPersonBaseUrl = "https://www.imdb.com/name/"
    static let youtubeBaseUrl = "https://www.youtube.com/watch?v="
    
    static let movieType = "movie_type"
    static let tvType = "tv_type"
    
    static let movieResponseType = "movie"
    static let tvShowResponseType = "tv"
}

enum NavigateType {
    case personView
    case detailView
}
