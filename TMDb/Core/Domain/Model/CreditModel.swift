//
//  CreditModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct CreditModel: Identifiable, Equatable {
    let id: Int
    let name: String
    let profilePath: String
    let characterName: String
    let order: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case characterName = "character"
        case order
    }
}
