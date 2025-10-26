import SwiftUI

struct AppVibrantTheme {
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

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Text("Clean App Theme Preview")
                .font(.largeTitle.bold())
                .foregroundColor(AppVibrantTheme.textPrimary)
            
            Text("iOS system background with green, orange, and purple accents")
                .font(.subheadline)
                .foregroundColor(AppVibrantTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            // Primary accent colors
            VStack(spacing: 15) {
                Text("Primary Accent Colors")
                    .font(.headline)
                    .foregroundColor(AppVibrantTheme.textPrimary)
                
                HStack(spacing: 15) {
                    AccentColorCard(color: AppVibrantTheme.green, name: "Green", lightColor: AppVibrantTheme.greenLight)
                    AccentColorCard(color: AppVibrantTheme.orange, name: "Orange", lightColor: AppVibrantTheme.orangeLight)
                    AccentColorCard(color: AppVibrantTheme.purple, name: "Purple", lightColor: AppVibrantTheme.purpleLight)
                }
            }
            
            // Example UI elements
            VStack(spacing: 15) {
                Text("Example UI Elements")
                    .font(.headline)
                    .foregroundColor(AppVibrantTheme.textPrimary)
                
                // Buttons
                HStack(spacing: 10) {
                    Button("Green Action") {}
                        .buttonStyle(AccentButtonStyle(color: AppVibrantTheme.green))
                    
                    Button("Orange Action") {}
                        .buttonStyle(AccentButtonStyle(color: AppVibrantTheme.orange))
                    
                    Button("Purple Action") {}
                        .buttonStyle(AccentButtonStyle(color: AppVibrantTheme.purple))
                }
                
                // Card example
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppVibrantTheme.cardBackground)
                    .overlay(
                        VStack {
                            Text("Sample Card")
                                .font(.headline)
                                .foregroundColor(AppVibrantTheme.textPrimary)
                            Text("Clean iOS system background with subtle shadows")
                                .font(.caption)
                                .foregroundColor(AppVibrantTheme.textSecondary)
                        }
                        .padding()
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .frame(height: 80)
            }
        }
        .padding()
    }
    .background(AppVibrantTheme.backgroundPrimary)
}

struct AccentColorCard: View {
    let color: Color
    let name: String
    let lightColor: Color
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 40)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(lightColor)
                .frame(height: 20)
            
            Text(name)
                .font(.caption.bold())
                .foregroundColor(AppVibrantTheme.textPrimary)
        }
    }
}

struct AccentButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(AppVibrantTheme.textOnColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color.opacity(configuration.isPressed ? 0.8 : 1.0))
            .cornerRadius(8)
    }
}