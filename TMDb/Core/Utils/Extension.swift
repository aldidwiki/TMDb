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
        guard let outDate = dateFormatter.date(from: self) else {
            return ""
        }
        
        dateFormatter.dateFormat = outFormat
        return dateFormatter.string(from: outDate)
    }
    
    func ageFormatter(_ inFormat: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = inFormat
        let currentDate = Date()
        
        var age = 0
        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: date, to: currentDate)
            age = ageComponents.year!
        }
        
        return String(age)
    }
}

extension Int? {
    func formatRuntime() -> String {
        var runtimeText = ""
        if let runtime = self {
            let hours = runtime / 60
            let minutes = runtime % 60
            
            if hours <= 0 {
                runtimeText = "\(minutes)m"
            } else {
                runtimeText = "\(hours)h \(minutes)m"
            }
        }
        
        return runtimeText
    }
}

extension Int64 {
    func formatCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en-US")
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        if let str = formatter.string(for: self) {
            return str
        }
        
        return String(self)
    }
}

extension Date {
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
