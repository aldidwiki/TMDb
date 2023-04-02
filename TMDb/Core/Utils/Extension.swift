//
//  Extension.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation

extension String {
    func formatDateString(input inFormat: String = "yyyy-MM-dd", output outFormat: String = "dd MMMM yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inFormat
        let outDate = dateFormatter.date(from: self) ?? Date()
        
        dateFormatter.dateFormat = outFormat
        return dateFormatter.string(from: outDate)
    }
}
