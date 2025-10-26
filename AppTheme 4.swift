import SwiftUI

struct AppThemeVibrant {
    static let green: Color = Color(.sRGB, red: 0.2, green: 0.75, blue: 0.35, opacity: 1)
    static let orange: Color = Color(.sRGB, red: 1.0, green: 0.6, blue: 0.0, opacity: 1)
    static let purple: Color = Color(.sRGB, red: 0.55, green: 0.35, blue: 0.95, opacity: 1)
    static let blue: Color = Color(.sRGB, red: 0.2, green: 0.5, blue: 1.0, opacity: 1)
    static let pink: Color = Color(.sRGB, red: 1.0, green: 0.3, blue: 0.6, opacity: 1)
    static let yellow: Color = Color(.sRGB, red: 1.0, green: 0.85, blue: 0.2, opacity: 1)
    static let redAccent: Color = Color(.sRGB, red: 0.95, green: 0.25, blue: 0.25, opacity: 1)
    static let greenAccent: Color = Color(.sRGB, red: 0.0, green: 0.75, blue: 0.5, opacity: 1)
    static let purpleAccent: Color = Color(.sRGB, red: 0.6, green: 0.4, blue: 1.0, opacity: 1)
    
    static let mainGradient: LinearGradient = LinearGradient(
        colors: [purple, blue, green],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient: LinearGradient = LinearGradient(
        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let funGradient: LinearGradient = LinearGradient(
        colors: [pink, yellow, orange],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let cardBackground: Color = Color.white
    static let backgroundSecondary: Color = Color(white: 0.96)
    
    static let textPrimary: Color = Color.primary
    static let textSecondary: Color = Color.secondary
    static let textOnColor: Color = Color.white
}

typealias KidTheme = AppThemeVibrant
