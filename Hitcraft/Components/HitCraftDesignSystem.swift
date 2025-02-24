// HitCraftDesignSystem.swift
import SwiftUI

enum HitCraftColors {
    static let background = Color(hex: "F4F4F5")
    static let border = Color(hex: "D9D9DF")
    static let cardBackground = Color(hex: "EFE9F4")
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "8A44C8"), Color(hex: "DF0C39")],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let accent = Color(hex: "D91A5A")
    static let text = Color(hex: "343434")
    static let secondaryText = Color(hex: "666666")
}

enum HitCraftFonts {
    static func poppins(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("Poppins-Bold", size: size)
        case .semibold:
            return .custom("Poppins-SemiBold", size: size)
        case .medium:
            return .custom("Poppins-Medium", size: size)
        case .light:
            return .custom("Poppins-Light", size: size)
        default:
            return .custom("Poppins-Regular", size: size)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
