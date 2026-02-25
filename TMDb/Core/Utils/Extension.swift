//
//  Extension.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation
import UIKit
import DominantColors
import SwiftUI

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

extension Double {
    func toPercentage(maxFragtionDigits fragtionDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = fragtionDigits
        formatter.locale = Locale(identifier: "en-US")
        
        if let str = formatter.string(for: self) {
            return str
        }
        
        return String(self)
    }
}

extension Int {
    func formatRuntime() -> String {
        var runtimeText = ""
        let hours = self / 60
        let minutes = self % 60
        
        if hours <= 0 {
            runtimeText = "\(minutes)m"
        } else {
            runtimeText = "\(hours)h \(minutes)m"
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

extension Array {
    func take(length: Int) -> [Element] {
        if self.count < length {
            return Array(self.prefix(self.count))
        } else {
            return Array(self.prefix(length))
        }
    }
}

extension [GenreResponseModel] {
    func formatGenres() -> String {
        var genres = ""
        let sortedGenre = self.sorted { genre1, genre2 in
            genre1.genreName < genre2.genreName
        }
        for genre in sortedGenre {
            if genre == sortedGenre.last {
                genres += "\(genre.genreName)"
            } else {
                genres += "\(genre.genreName), "
            }
        }
        
        return genres
    }
}

extension [SpokenLanguageResponse] {
    func formatSpokenLanguage() -> String {
        var spokenLanguage = ""
        for spokenLangRes in self {
            spokenLanguage += spokenLangRes.englishName ?? ""
            if spokenLangRes.englishName != self.last?.englishName {
                spokenLanguage += "\n"
            }
        }
        
        return spokenLanguage
    }
}

extension UIImage {
    func extractPalette(completion : @escaping (Color, Color, Color) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let dominantColors = try self.dominantColors().map { $0.cgColor }
                
                if let contrastColors = ContrastColors(colors: dominantColors) {
                    DispatchQueue.main.async {
                        let bgColor = Color(uiColor: UIColor(cgColor: contrastColors.background))
                        let primaryColor = Color(uiColor: UIColor(cgColor: contrastColors.primary))
                        var secondaryColor: Color = .primary
                        
                        if let secondary = contrastColors.secondary {
                            secondaryColor = Color(uiColor: UIColor(cgColor: secondary))
                        }
                        
                        completion(bgColor, primaryColor, secondaryColor)
                    }
                }
            } catch {
                print("Error extracting colors")
            }
        }
    }
}

extension View {
    func debugPrint(_ value: Any) -> some View {
        print(value)
        return self
    }
    
    func elevation(_ size: CGFloat) -> some View {
        self.overlay(
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.3), .clear]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: size)
            .offset(y: size), // Moves it just below the bottom edge
            alignment: .bottom
        )
    }
}
