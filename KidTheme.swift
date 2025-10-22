// KidTheme.swift
// Define a playful, vibrant color palette and gradients for the whole app in one place.

import SwiftUI

struct KidTheme {
    // Fun, kid-friendly accent colors
    static let purple = Color(red: 147/255, green: 85/255, blue: 226/255) // Bright purple
    static let blue = Color(red: 80/255, green: 180/255, blue: 255/255)   // Sky blue
    static let green = Color(red: 120/255, green: 220/255, blue: 110/255) // Fresh green
    static let orange = Color(red: 255/255, green: 165/255, blue: 80/255) // Vivid orange
    static let pink = Color(red: 255/255, green: 115/255, blue: 185/255)  // Hot pink
    static let yellow = Color(red: 255/255, green: 220/255, blue: 90/255) // Lemon yellow

    // Gradient for large dashboards or backgrounds
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

    // Use these for accenting icons, progress bars, buttons, etc.
}
