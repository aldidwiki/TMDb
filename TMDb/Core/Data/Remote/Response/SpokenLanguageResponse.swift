//
//  SpokenLanguageResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 09/05/23.
//

import Foundation

struct SpokenLanguageResponse: Decodable {
    let englishName: String?
    let iso6391: String?
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso6391 = "iso_639_1"
        case name
    }
}
