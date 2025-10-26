import SwiftUI

public struct KidTheme {
    // A vibrant background gradient for full-screen backgrounds
    public static let mainGradient: LinearGradient = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.63, blue: 0.13), // orange
            Color(red: 0.94, green: 0.28, blue: 0.36), // pink/red
            Color(red: 0.53, green: 0.61, blue: 0.99)  // periwinkle
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // A playful card gradient for containers
    public static let cardGradient: LinearGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.86, blue: 1.0).opacity(0.9), // soft lavender
            Color(red: 0.86, green: 0.96, blue: 1.0).opacity(0.9)  // soft sky
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // A bold accent color used for primary buttons
    public static let purple: Color = Color(red: 0.56, green: 0.27, blue: 0.68)
}
