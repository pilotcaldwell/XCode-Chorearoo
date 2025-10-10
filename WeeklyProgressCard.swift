import SwiftUI
import CoreData

struct WeeklyProgressCard: View {
    let child: Child
    let choreEarnings: Double
    let bonusEarnings: Double
    let weeklyCap: Double
    
    var totalThisWeek: Double {
        choreEarnings + bonusEarnings
    }
    
    var remainingToEarn: Double {
        max(0, weeklyCap - choreEarnings)
    }
    
    var progressPercentage: Double {
        min(1.0, choreEarnings / weeklyCap)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "clock.badge.checkmark.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("This Week")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Approved")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(20)
            }
            
            // Total Amount
            Text(String(format: "$%.2f", totalThisWeek))
                .font(.system(size: 48, weight: .bold))
            
            // Breakdown
            VStack(alignment: .leading, spacing: 4) {
                Text(String(format: "Chores: $%.2f of $%.2f cap", choreEarnings, weeklyCap))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if bonusEarnings > 0 {
                    Text(String(format: "+ $%.2f bonus (extra!)", bonusEarnings))
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 20)
                        
                        // Chore earnings progress
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.purple)
                            .frame(width: geometry.size.width * progressPercentage, height: 20)
                        
                        // Bonus section (if applicable)
                        if bonusEarnings > 0 {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * min(0.3, (bonusEarnings / weeklyCap)), height: 20)
                                .offset(x: geometry.size.width * progressPercentage)
                        }
                    }
                }
                .frame(height: 20)
                
                Text(String(format: "$%.2f chore earnings remaining", remainingToEarn))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
}

#Preview {
    WeeklyProgressCard(
        child: Child(),
        choreEarnings: 8.50,
        bonusEarnings: 7.50,
        weeklyCap: 10.0
    )
}
