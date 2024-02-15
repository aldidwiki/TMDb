//
//  API.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import Alamofire

class API {
    static let baseUrl = "https://api.themoviedb.org/3/"
    static let imageBaseUrl = "https://image.tmdb.org/t/p/w500"
    static let backdropBaseUrl = "https://image.tmdb.org/t/p/w1280"
    static let profileImageBaseUrl = "https://image.tmdb.org/t/p/h632"
    static let profileOriginalBaseUrl = "https://image.tmdb.org/t/p/original"
    static let logoImageBaseUrl = "https://image.tmdb.org/t/p/w92"
    static let episodeStillBaseUrl = "https://image.tmdb.org/t/p/w300"
    
    static let headers: HTTPHeaders = [
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNTBlZjRkN2I0ZDNjOTk1MzUxOGE2ZTJlZDQ5OTI4ZSIsInN1YiI6IjVmZDZkYjUyZDhlMjI1MDA0MTFiMzZlMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.ObyQC30cOIxcfWiFBzp4mFX3BMxsQky6BXnONZtrzQw",
        "accept": "application/json"
    ]
}
