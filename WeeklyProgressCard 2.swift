import SwiftUI
import CoreData

struct WeeklyProgressCard: View {
    let child: Child
    let choreEarnings: Double
    let bonusEarnings: Double
    let weeklyCap: Double
    
    private var totalEarnings: Double {
        choreEarnings + bonusEarnings
    }
    
    private var remainingCap: Double {
        max(0, weeklyCap - totalEarnings)
    }
    
    private var progressPercentage: Double {
        guard weeklyCap > 0 else { return 0 }
        return min(1.0, totalEarnings / weeklyCap)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weekly Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("$\(String(format: "%.2f", totalEarnings)) / $\(String(format: "%.2f", weeklyCap))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [Color.green.opacity(0.7), Color.green],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * progressPercentage, height: 12)
                            .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                    }
                }
                .frame(height: 12)
                
                // Progress details
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chores")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", choreEarnings))")
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Bonuses")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", bonusEarnings))")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", remainingCap))")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(remainingCap > 0 ? .blue : .red)
                    }
                }
            }
            
            // Weekly status message
            if totalEarnings >= weeklyCap {
                Text("🎉 Weekly goal reached!")
                    .font(.footnote)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            } else {
                Text("Keep going! $\(String(format: "%.2f", remainingCap)) left to reach your weekly goal.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    WeeklyProgressCard(
        child: Child(), // This would need a proper Child object in real usage
        choreEarnings: 7.50,
        bonusEarnings: 2.50,
        weeklyCap: 15.00
    )
    .padding()
    .previewLayout(.sizeThatFits)
}