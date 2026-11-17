import SwiftUI

enum DashboardDesign {
    static let contentWidth: CGFloat = 560
    static let contentInset: CGFloat = 18
    static let background = color(0xF9F9FF)
    static let surface = color(0xFFFFFF)
    static let surfaceDim = color(0xF1F3FF)
    static let border = color(0xE2E6F4)
    static let accent = color(0x3B4CCA)
    static let accentPressed = color(0x2D3CA8)
    static let text = color(0x0F172A)
    static let secondaryText = color(0x64748B)
    static let rating = color(0xF59E0B)
    static let mediaFooter = color(0x141B2B)
    static let mediaFooterGradient = LinearGradient(
        colors: [mediaFooter.opacity(0.95), mediaFooter.opacity(0)],
        startPoint: .bottom,
        endPoint: .top
    )
    static let indicator = color(0xDCE2F7)
    static let controlRadius: CGFloat = 12
    static let cardRadius: CGFloat = 16

    static func color(_ hex: UInt32) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
