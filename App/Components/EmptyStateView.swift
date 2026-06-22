import SwiftUI

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundStyle(.secondary.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
    }
}
