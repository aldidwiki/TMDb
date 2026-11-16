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
    let popularity: Double
    let releaseDate: String
    let episodeCount: Int
    let mediaType: String
    var isCrewCredit = false

    static func castInBillingOrder(_ credits: [Self]) -> [Self] {
        var seen: Set<Int> = []
        return credits.sorted { $0.order < $1.order }.filter { credit in
            credit.id > 0 && !credit.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && seen.insert(credit.id).inserted
        }
    }
}
