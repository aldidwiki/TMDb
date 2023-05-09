//
//  PersonModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct PersonModel: Identifiable, Equatable {
    let id: Int
    let name: String
    let profilePath: String
    let birthday: String
    let deathday: String
    let gender: String
    let biography: String
    let birthplace: String
    let knownFor: String
}
