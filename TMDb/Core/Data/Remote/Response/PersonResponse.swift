//
//  PersonResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct PersonResponse: Decodable {
    let id: Int
    let name: String?
    let profilePath: String?
    let birthday: String?
    let deathday: String?
    let gender: Int?
    let biography: String?
    let birthplace: String?
    let knownFor: String?
    let credits: PersonCreditResponse
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case birthday
        case deathday
        case gender
        case biography
        case birthplace = "place_of_birth"
        case knownFor = "known_for_department"
        case credits = "movie_credits"
    }
}
