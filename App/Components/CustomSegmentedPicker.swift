import SwiftUI

struct CustomSegmentedPicker<T: Hashable>: View {
    let options: [T]
    let title: (T) -> String
    @Binding var selection: T
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let isSelected = selection == option
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = option
                    }
                }) {
                    Text(title(option))
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? Color.white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                if isSelected {
                                    Capsule()
                                        .fill(AppTheme.primary)
                                        .matchedGeometryEffect(id: "activeTab", in: animation)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
        .padding(4)
        .background(AppTheme.bgCard)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}
