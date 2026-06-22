import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let showDivider: Bool
    
    // Optional setting for background color to adapt between List and normal VStack
    var isListRow: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
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
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text((transaction.type == .income ? "+" : "-") + transaction.formattedAmount)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(transaction.type == .income ? AppTheme.income : AppTheme.expense)
                
                Text("Success")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.vertical, isListRow ? 8 : 12)
        .padding(.horizontal, isListRow ? 0 : 16)
        .background(
            VStack {
                Spacer()
                if showDivider {
                    Divider().padding(.leading, 76)
                }
            }
        )
    }
}
