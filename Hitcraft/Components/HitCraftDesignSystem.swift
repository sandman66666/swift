// HitCraftDesignSystem.swift
import SwiftUI

enum HitCraftColors {
    // MARK: - Dynamic Colors (Light/Dark aware)
    
    // Background colors
    static var background: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "121212") : Color(hex: "F2F2F2")
    }
    
    static var cardBackground: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "1E1E1E") : Color.white
    }
    
    static var userMessageBackground: Color {
        ThemeManager.shared.currentTheme == .dark ?
            Color(hex: "FF4A7D").opacity(0.15) : Color(hex: "FF4A7D").opacity(0.1)
    }
    
    static var systemMessageBackground: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "2A2A2A") : Color(hex: "F2F2F2")
    }
    
    // Text colors
    static var text: Color {
        ThemeManager.shared.currentTheme == .dark ? Color.white : Color(hex: "333333")
    }
    
    static var secondaryText: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "B0B0B0") : Color(hex: "666666")
    }
    
    // UI elements
    static var border: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "333333") : Color(hex: "E0E0E0")
    }
    
    static var headerFooterBackground: Color {
        ThemeManager.shared.currentTheme == .dark ? Color(hex: "1A1A1A") : Color(hex: "F9F9F9")
    }
    
    // MARK: - Fixed Colors (Same in both themes)
    
    // Primary colors
    static let accent = Color(hex: "FF4A7D")            // Primary Pink
    static let accentHover = Color(hex: "FF6F92")       // Secondary Pink (hover/pressed state)
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "FF4A7D"), Color(hex: "FF6F92")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // For backward compatibility
    static var darkAreaColor: Color {
        headerFooterBackground
    }
}

enum HitCraftFonts {
    // Header (e.g., "CHAT")
    static func header() -> Font {
        return .custom("Poppins-Bold", size: 20)
    }
    
    // Subheader / Section Title
    static func subheader() -> Font {
        return .custom("Poppins-SemiBold", size: 17)
    }
    
    // Body / Chat Messages
    static func body() -> Font {
        return .custom("Poppins-Regular", size: 16)
    }
    
    // Tab Labels / Small Text
    static func caption() -> Font {
        return .custom("Poppins-Medium", size: 14)
    }
    
    // For backward compatibility and custom sizes
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

// Shadow styles
enum HitCraftShadows {
    static var subtle: Shadow {
        ThemeManager.shared.currentTheme == .dark ?
            Shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2) :
            Shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    static var light: Shadow {
        ThemeManager.shared.currentTheme == .dark ?
            Shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1) :
            Shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func apply<T: View>(to view: T) -> some View {
        view.shadow(color: color, radius: radius, x: x, y: y)
    }
}

// Layout constants
enum HitCraftLayout {
    static let standardPadding: CGFloat = 16
    static let messagePadding: CGFloat = 14         // Chat bubble padding
    static let itemSpacing: CGFloat = 12
    static let messageBubbleSpacing: CGFloat = 10   // Space between chat bubbles
    static let cornerRadius: CGFloat = 8            // Input field corner radius
    static let messageBubbleRadius: CGFloat = 10    // Chat bubble corner radius
    static let cardCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 20
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

// Button styles
struct HitCraftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Extension to create standard button styles
extension View {
    func hitCraftStyle() -> some View {
        self.buttonStyle(HitCraftButtonStyle())
    }
}
