import SwiftUI

struct AppTheme {
    // Primary accent colors - clean and readable
    static let green: Color = Color(.sRGB, red: 0.2, green: 0.7, blue: 0.3, opacity: 1)
    static let orange: Color = Color(.sRGB, red: 0.95, green: 0.5, blue: 0.1, opacity: 1)
    static let purple: Color = Color(.sRGB, red: 0.6, green: 0.4, blue: 0.8, opacity: 1)
    
    // Lighter versions for subtle backgrounds
    static let greenLight: Color = Color(.sRGB, red: 0.9, green: 0.95, blue: 0.9, opacity: 1)
    static let orangeLight: Color = Color(.sRGB, red: 0.98, green: 0.94, blue: 0.9, opacity: 1)
    static let purpleLight: Color = Color(.sRGB, red: 0.95, green: 0.92, blue: 0.98, opacity: 1)
    
    // Background colors - using iOS system colors like the approvals page  
    static let backgroundPrimary: Color = Color(.systemBackground) // Clean iOS system background
    static let backgroundSecondary: Color = Color(.secondarySystemBackground) // iOS secondary background  
    static let cardBackground: Color = Color(.systemBackground) // iOS system card background
    
    // Text colors (darker for better contrast)
    static let textPrimary: Color = Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1) // Darker for better contrast
    static let textSecondary: Color = Color(.sRGB, red: 0.4, green: 0.4, blue: 0.4, opacity: 1) // Darker secondary text
    static let textOnColor: Color = Color.white
    
    // Simple gradients - very subtle
    static let mainGradient: LinearGradient = LinearGradient(
        colors: [backgroundPrimary, backgroundSecondary],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient: LinearGradient = LinearGradient(
        colors: [cardBackground, Color(.secondarySystemBackground)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Accent gradient - for special elements only
    static let accentGradient: LinearGradient = LinearGradient(
        colors: [green.opacity(0.8), purple.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Legacy colors for compatibility (mapped to new simple colors)
    static let blue: Color = purple
    static let pink: Color = purple
    static let yellow: Color = orange
    static let redAccent: Color = orange
    static let greenAccent: Color = green
    static let purpleAccent: Color = purple
    static let funGradient: LinearGradient = accentGradient
}