import SwiftUI

// Basic app-wide theme definition to replace corrupted content
public struct AppTheme: Sendable, Equatable {
    public var primaryColor: Color
    public var secondaryColor: Color
    public var backgroundColor: Color
    public var accentColor: Color
    public var cornerRadius: CGFloat

    public init(primaryColor: Color = .blue,
                secondaryColor: Color = .teal,
                backgroundColor: Color = Color(.systemBackground),
                accentColor: Color = .orange,
                cornerRadius: CGFloat = 12) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
    }
}

public extension AppTheme {
    static let `default` = AppTheme()
}

// Optional environment key for easy injection across views
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .default
}

public extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

public extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}

// MARK: - Static KidTheme-style palette and surfaces
public extension AppTheme {
    // Core palette
    static let green: Color = Color(hue: 0.35, saturation: 0.70, brightness: 0.70) // friendly green
    static let purple: Color = Color(hue: 0.76, saturation: 0.55, brightness: 0.70)
    static let orange: Color = Color(hue: 0.08, saturation: 0.85, brightness: 0.95)
    static let pink: Color = Color(hue: 0.94, saturation: 0.55, brightness: 0.95)
    static let yellow: Color = Color(hue: 0.14, saturation: 0.85, brightness: 0.95)
    static let blue: Color = Color(hue: 0.58, saturation: 0.65, brightness: 0.85)

    // Accents
    static let redAccent: Color = Color(red: 0.95, green: 0.30, blue: 0.35)
    static let greenAccent: Color = Color(red: 0.20, green: 0.75, blue: 0.45)
    static let purpleAccent: Color = Color.purple.opacity(0.15)

    // Text
    static let textPrimary: Color = Color.primary
    static let textSecondary: Color = Color.secondary
    static let textOnColor: Color = Color.white

    // Surfaces / backgrounds
    static let cardBackground: Color = Color(.secondarySystemBackground)
    static let backgroundSecondary: Color = Color(.systemGroupedBackground)

    // Gradients
    static let cardGradient: LinearGradient = LinearGradient(
        colors: [
            Color.purple.opacity(0.12),
            Color.blue.opacity(0.12),
            Color.cyan.opacity(0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let mainGradient: LinearGradient = LinearGradient(
        colors: [
            Color.purple.opacity(0.15),
            Color.orange.opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let funGradient: LinearGradient = LinearGradient(
        colors: [
            Color.pink,
            Color.orange
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
