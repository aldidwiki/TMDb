//
//  ColorPalette.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct ColorPalette: Hashable {
    let background: Color
    let title: Color
    let subtitle: Color
    let primaryAccent: Color
    let secondaryAccent: Color
    let tertiaryAccent: Color
}

extension ColorPalette {
    static let vibrantCool = ColorPalette(
        background: Color(red: 244/255, green: 250/255, blue: 250/255),
        title: Color(red: 45/255, green: 27/255, blue: 78/255),
        subtitle: Color(red: 88/255, green: 111/255, blue: 124/255),
        primaryAccent: Color(red: 255/255, green: 107/255, blue: 107/255),
        secondaryAccent: Color(red: 67/255, green: 170/255, blue: 139/255),
        tertiaryAccent: Color(red: 249/255, green: 199/255, blue: 79/255)
    )
    
    static let warmEarthy = ColorPalette(
        background: Color(red: 255/255, green: 249/255, blue: 240/255),
        title: Color(red: 26/255, green: 54/255, blue: 93/255),
        subtitle: Color(red: 121/255, green: 85/255, blue: 72/255),
        primaryAccent: Color(red: 226/255, green: 88/255, blue: 34/255),
        secondaryAccent: Color(red: 46/255, green: 139/255, blue: 87/255),
        tertiaryAccent: Color(red: 74/255, green: 144/255, blue: 226/255)
    )
    
    static let pastelPlayful = ColorPalette(
        background: Color(red: 252/255, green: 248/255, blue: 255/255),
        title: Color(red: 44/255, green: 62/255, blue: 80/255),
        subtitle: Color(red: 134/255, green: 107/255, blue: 157/255),
        primaryAccent: Color(red: 217/255, green: 70/255, blue: 239/255),
        secondaryAccent: Color(red: 14/255, green: 165/255, blue: 233/255),
        tertiaryAccent: Color(red: 245/255, green: 158/255, blue: 11/255)
    )
    
    static let natureBotanical = ColorPalette(
        background: Color(red: 245/255, green: 247/255, blue: 243/255),
        title: Color(red: 30/255, green: 57/255, blue: 42/255),
        subtitle: Color(red: 92/255, green: 116/255, blue: 106/255),
        primaryAccent: Color(red: 211/255, green: 84/255, blue: 0/255),
        secondaryAccent: Color(red: 142/255, green: 68/255, blue: 173/255),
        tertiaryAccent: Color(red: 41/255, green: 128/255, blue: 185/255)
    )
    
    static let corporateTrust = ColorPalette(
        background: Color(red: 240/255, green: 244/255, blue: 248/255),
        title: Color(red: 15/255, green: 41/255, blue: 66/255),
        subtitle: Color(red: 82/255, green: 106/255, blue: 130/255),
        primaryAccent: Color(red: 227/255, green: 0/255, blue: 82/255),
        secondaryAccent: Color(red: 0/255, green: 180/255, blue: 216/255),
        tertiaryAccent: Color(red: 255/255, green: 183/255, blue: 3/255)
    )
    
    static let modernRetro = ColorPalette(
        background: Color(red: 253/255, green: 245/255, blue: 230/255),
        title: Color(red: 74/255, green: 37/255, blue: 17/255),
        subtitle: Color(red: 139/255, green: 90/255, blue: 43/255),
        primaryAccent: Color(red: 42/255, green: 157/255, blue: 143/255),
        secondaryAccent: Color(red: 231/255, green: 111/255, blue: 81/255),
        tertiaryAccent: Color(red: 233/255, green: 196/255, blue: 106/255)
    )
    
    static let palettes: [ColorPalette] = [
        vibrantCool,
        pastelPlayful,
        natureBotanical,
        corporateTrust,
        modernRetro,
        warmEarthy
    ]
}
