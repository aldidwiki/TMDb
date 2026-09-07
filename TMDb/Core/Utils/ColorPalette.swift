//
//  ColorPalette.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct ColorPalette: Hashable {
    let background: Color
    let surface: Color
    let title: Color
    let subtitle: Color
    let primaryAccent: Color
    let secondaryAccent: Color
    let tertiaryAccent: Color
    let success: Color
    let warning: Color
    let error: Color
}

extension ColorPalette {
    // 1. Cyber Aqua
    static let vibrantCool = ColorPalette(
        background: Color(red: 200/255, green: 245/255, blue: 255/255),
        surface: Color(red: 225/255, green: 250/255, blue: 255/255),
        title: Color(red: 20/255, green: 0/255, blue: 100/255),
        subtitle: Color(red: 50/255, green: 20/255, blue: 150/255),
        primaryAccent: Color(red: 255/255, green: 0/255, blue: 100/255),
        secondaryAccent: Color(red: 0/255, green: 150/255, blue: 255/255),
        tertiaryAccent: Color(red: 255/255, green: 220/255, blue: 0/255),
        success: Color(red: 0/255, green: 230/255, blue: 100/255),
        warning: Color(red: 255/255, green: 150/255, blue: 0/255),
        error: Color(red: 255/255, green: 20/255, blue: 80/255)
    )
    
    // 2. Solar Flare
    static let warmEarthy = ColorPalette(
        background: Color(red: 255/255, green: 230/255, blue: 200/255),
        surface: Color(red: 255/255, green: 240/255, blue: 215/255),
        title: Color(red: 80/255, green: 0/255, blue: 0/255),
        subtitle: Color(red: 150/255, green: 30/255, blue: 0/255),
        primaryAccent: Color(red: 255/255, green: 50/255, blue: 0/255),
        secondaryAccent: Color(red: 0/255, green: 180/255, blue: 200/255),
        tertiaryAccent: Color(red: 0/255, green: 100/255, blue: 255/255),
        success: Color(red: 50/255, green: 200/255, blue: 80/255),
        warning: Color(red: 255/255, green: 180/255, blue: 0/255),
        error: Color(red: 220/255, green: 0/255, blue: 40/255)
    )
    
    // 3. Bubblegum Strike
    static let pastelPlayful = ColorPalette(
        background: Color(red: 255/255, green: 220/255, blue: 240/255),
        surface: Color(red: 255/255, green: 235/255, blue: 248/255),
        title: Color(red: 60/255, green: 0/255, blue: 80/255),
        subtitle: Color(red: 120/255, green: 0/255, blue: 150/255),
        primaryAccent: Color(red: 200/255, green: 0/255, blue: 255/255),
        secondaryAccent: Color(red: 0/255, green: 200/255, blue: 255/255),
        tertiaryAccent: Color(red: 255/255, green: 180/255, blue: 0/255),
        success: Color(red: 0/255, green: 230/255, blue: 130/255),
        warning: Color(red: 255/255, green: 140/255, blue: 0/255),
        error: Color(red: 255/255, green: 0/255, blue: 100/255)
    )
    
    // 4. Toxic Jungle
    static let natureBotanical = ColorPalette(
        background: Color(red: 200/255, green: 255/255, blue: 210/255),
        surface: Color(red: 225/255, green: 255/255, blue: 230/255),
        title: Color(red: 0/255, green: 50/255, blue: 10/255),
        subtitle: Color(red: 0/255, green: 100/255, blue: 30/255),
        primaryAccent: Color(red: 255/255, green: 80/255, blue: 0/255),
        secondaryAccent: Color(red: 120/255, green: 0/255, blue: 255/255),
        tertiaryAccent: Color(red: 0/255, green: 150/255, blue: 255/255),
        success: Color(red: 0/255, green: 200/255, blue: 50/255),
        warning: Color(red: 255/255, green: 200/255, blue: 0/255),
        error: Color(red: 255/255, green: 50/255, blue: 50/255)
    )
    
    // 5. Power Blue
    static let corporateTrust = ColorPalette(
        background: Color(red: 210/255, green: 230/255, blue: 255/255),
        surface: Color(red: 235/255, green: 245/255, blue: 255/255),
        title: Color(red: 0/255, green: 10/255, blue: 60/255),
        subtitle: Color(red: 10/255, green: 50/255, blue: 150/255),
        primaryAccent: Color(red: 255/255, green: 0/255, blue: 40/255),
        secondaryAccent: Color(red: 0/255, green: 180/255, blue: 255/255),
        tertiaryAccent: Color(red: 255/255, green: 150/255, blue: 0/255),
        success: Color(red: 0/255, green: 200/255, blue: 120/255),
        warning: Color(red: 255/255, green: 180/255, blue: 0/255),
        error: Color(red: 220/255, green: 20/255, blue: 60/255)
    )
    
    // 6. Tangerine Pop
    static let modernRetro = ColorPalette(
        background: Color(red: 255/255, green: 225/255, blue: 180/255),
        surface: Color(red: 255/255, green: 235/255, blue: 200/255),
        title: Color(red: 60/255, green: 15/255, blue: 0/255),
        subtitle: Color(red: 150/255, green: 50/255, blue: 0/255),
        primaryAccent: Color(red: 0/255, green: 120/255, blue: 120/255),
        secondaryAccent: Color(red: 255/255, green: 20/255, blue: 0/255),
        tertiaryAccent: Color(red: 100/255, green: 0/255, blue: 200/255),
        success: Color(red: 40/255, green: 160/255, blue: 80/255),
        warning: Color(red: 255/255, green: 140/255, blue: 0/255),
        error: Color(red: 200/255, green: 0/255, blue: 50/255)
    )
    
    // 7. Lemon Shock (Electric Yellow Base with Magenta & Cyan)
    static let lemonShock = ColorPalette(
        background: Color(red: 255/255, green: 250/255, blue: 150/255),
        surface: Color(red: 255/255, green: 255/255, blue: 180/255),
        title: Color(red: 30/255, green: 0/255, blue: 80/255),
        subtitle: Color(red: 100/255, green: 50/255, blue: 150/255),
        primaryAccent: Color(red: 255/255, green: 0/255, blue: 150/255),
        secondaryAccent: Color(red: 0/255, green: 255/255, blue: 255/255),
        tertiaryAccent: Color(red: 255/255, green: 100/255, blue: 0/255),
        success: Color(red: 0/255, green: 180/255, blue: 60/255),
        warning: Color(red: 255/255, green: 120/255, blue: 0/255),
        error: Color(red: 220/255, green: 0/255, blue: 20/255)
    )
    
    // 8. Lavender Punch (Vivid Purple Base with Lime & Coral)
    static let lavenderPunch = ColorPalette(
        background: Color(red: 230/255, green: 200/255, blue: 255/255),
        surface: Color(red: 245/255, green: 225/255, blue: 255/255),
        title: Color(red: 10/255, green: 10/255, blue: 60/255),
        subtitle: Color(red: 20/255, green: 80/255, blue: 100/255),
        primaryAccent: Color(red: 150/255, green: 255/255, blue: 0/255),
        secondaryAccent: Color(red: 255/255, green: 80/255, blue: 80/255),
        tertiaryAccent: Color(red: 255/255, green: 220/255, blue: 0/255),
        success: Color(red: 0/255, green: 200/255, blue: 50/255),
        warning: Color(red: 255/255, green: 150/255, blue: 0/255),
        error: Color(red: 255/255, green: 0/255, blue: 50/255)
    )
    
    // 9. Coral Electric (Bright Peach-Pink Base with Teal & Violet)
    static let coralElectric = ColorPalette(
        background: Color(red: 255/255, green: 200/255, blue: 180/255),
        surface: Color(red: 255/255, green: 220/255, blue: 205/255),
        title: Color(red: 80/255, green: 0/255, blue: 20/255),
        subtitle: Color(red: 140/255, green: 50/255, blue: 80/255),
        primaryAccent: Color(red: 0/255, green: 200/255, blue: 200/255),
        secondaryAccent: Color(red: 150/255, green: 0/255, blue: 255/255),
        tertiaryAccent: Color(red: 0/255, green: 255/255, blue: 100/255),
        success: Color(red: 20/255, green: 180/255, blue: 80/255),
        warning: Color(red: 255/255, green: 180/255, blue: 0/255),
        error: Color(red: 200/255, green: 0/255, blue: 0/255)
    )
    
    // 10. Spring Glare (Intense Mint Base with Crimson & Bright Blue)
    static let springGlare = ColorPalette(
        background: Color(red: 180/255, green: 255/255, blue: 180/255),
        surface: Color(red: 210/255, green: 255/255, blue: 210/255),
        title: Color(red: 0/255, green: 60/255, blue: 20/255),
        subtitle: Color(red: 60/255, green: 100/255, blue: 40/255),
        primaryAccent: Color(red: 220/255, green: 0/255, blue: 50/255),
        secondaryAccent: Color(red: 120/255, green: 0/255, blue: 200/255),
        tertiaryAccent: Color(red: 0/255, green: 100/255, blue: 255/255),
        success: Color(red: 0/255, green: 180/255, blue: 40/255),
        warning: Color(red: 250/255, green: 130/255, blue: 0/255),
        error: Color(red: 255/255, green: 40/255, blue: 40/255)
    )
    
    static let palettes: [ColorPalette] = [
        vibrantCool,
        pastelPlayful,
        natureBotanical,
        corporateTrust,
        modernRetro,
        warmEarthy,
        lemonShock,
        lavenderPunch,
        coralElectric,
        springGlare
    ]
}
