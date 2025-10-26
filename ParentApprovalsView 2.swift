import SwiftUI

struct ParentApprovalsView: View {
    var body: some View {
        NavigationStack {
            Content()
                .navigationTitle("Approvals")
        }
    }
}

private struct Content: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("No approvals yet")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("When kids request chore approvals or redemptions, they'll appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                // Placeholder action
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ParentApprovalsView()
}
