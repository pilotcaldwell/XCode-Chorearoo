import SwiftUI

/// Kid-friendly theme configuration for the chorearoo app
/// Designed with high contrast, bright colors, and excellent readability
/// Note: Renamed to ParentAppTheme in this file to avoid conflicting with the global AppTheme.
struct ParentAppTheme {
    // Bright, kid-friendly basic colors with high contrast
    static let purple = Color(red: 138/255, green: 43/255, blue: 226/255)     // Vivid purple
    static let blue = Color(red: 30/255, green: 144/255, blue: 255/255)       // Bright blue
    static let green = Color(red: 34/255, green: 197/255, blue: 94/255)       // Fresh green
    static let orange = Color(red: 255/255, green: 149/255, blue: 0/255)      // Vibrant orange
    static let pink = Color(red: 255/255, green: 45/255, blue: 85/255)        // Hot pink
    static let yellow = Color(red: 255/255, green: 204/255, blue: 0/255)      // Sunny yellow
    static let red = Color(red: 255/255, green: 59/255, blue: 48/255)         // Bright red

    // Lighter accent colors for interactions and highlights
    static let greenAccent = Color(red: 52/255, green: 199/255, blue: 89/255)
    static let redAccent = Color(red: 255/255, green: 69/255, blue: 58/255)
    static let purpleAccent = Color(red: 191/255, green: 90/255, blue: 242/255)
    static let playfulColor = Color(red: 255/255, green: 45/255, blue: 85/255) // Hot pink for fun elements

    // Text colors with high contrast
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textOnColor = Color.white // White text on colored backgrounds

    // Clean, accessible backgrounds
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let cardBackground = Color(.systemBackground)
    
    // Subtle gradients that don't interfere with readability
    static let mainGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(.systemBackground),
            Color(.secondarySystemBackground)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(.systemBackground),
            Color(.systemGroupedBackground)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Fun accent gradients for special elements (use sparingly)
    static let funGradient = LinearGradient(
        gradient: Gradient(colors: [purple, pink]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        gradient: Gradient(colors: [green, greenAccent]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
