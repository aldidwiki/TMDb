//
//  PersonImageModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 15/02/24.
//

import Foundation

struct PersonImageModel: Identifiable {
    let filePath: String
    let aspectRatio: Double?

    var id: String { filePath }
}
