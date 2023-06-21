//
//  VideoModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 21/06/23.
//

import Foundation

struct VideoModel: Identifiable, Equatable {
    var id: String
    let key: String
    let name: String
    let site: String
    let type: String
}
