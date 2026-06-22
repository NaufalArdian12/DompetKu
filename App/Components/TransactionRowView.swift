import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let showDivider: Bool
    
    // Optional setting for background color to adapt between List and normal VStack
    var isListRow: Bool = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: transaction.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .stroke(Color(white: 0.85), lineWidth: 1)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white))
                .overlay(
                    Image(systemName: transaction.type == .income ? "arrow.down" : "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                )
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text((transaction.type == .income ? "+" : "") + (transaction.type == .expense ? "-" : "") + transaction.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(transaction.type == .income ? AppTheme.primary : AppTheme.expense)
                
                Text("Success")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, isListRow ? 8 : 16)
        .padding(.horizontal, isListRow ? 0 : 20)
        .background(
            VStack {
                Spacer()
                if showDivider {
                    Divider()
                        .background(Color(white: 0.9))
                        .padding(.leading, 80)
                        .padding(.trailing, 20)
                }
            }
        )
    }
}
