import SwiftUI

/// Main theme configuration for the chorearoo app
/// Contains all colors, gradients, and styling properties
struct AppTheme {
    // Basic colors
    static let purple = Color(red: 147/255, green: 85/255, blue: 226/255)
    static let blue = Color(red: 80/255, green: 180/255, blue: 255/255)
    static let green = Color(red: 120/255, green: 220/255, blue: 110/255)
    static let orange = Color(red: 255/255, green: 165/255, blue: 80/255)
    static let pink = Color(red: 255/255, green: 115/255, blue: 185/255)
    static let yellow = Color(red: 255/255, green: 220/255, blue: 90/255)
    static let red = Color(red: 255/255, green: 90/255, blue: 90/255)

    // Accent colors for buttons and interactions
    static let greenAccent = Color(red: 95/255, green: 215/255, blue: 80/255)
    static let redAccent = Color(red: 255/255, green: 90/255, blue: 90/255)
    static let purpleAccent = Color(red: 180/255, green: 100/255, blue: 255/255)
    static let playfulColor = Color(red: 255/255, green: 115/255, blue: 185/255) // Using pink for playful color

    // Text colors
    static let textPrimary = Color.primary

    // Gradients for backgrounds
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [purple, blue, pink]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white.opacity(0.7), blue.opacity(0.1)]),
        startPoint: .top,
        endPoint: .bottom
    )
}

/// Legacy alias for backwards compatibility
/// This allows existing code to continue using KidTheme
typealias KidTheme = AppTheme
