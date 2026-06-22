import SwiftUI

struct BalanceCardView: View {
    let currentBalance: Double
    let totalIncome: Double
    let totalExpense: Double
    var onAddTransaction: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            // Top Blue Header
            VStack(spacing: 20) {
                // Balance Section
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 8) {
                        Text("Total Saldo Anda")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                        Text(currentBalance.formattedRupiah)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1).minimumScaleFactor(0.6)
                    }
                    .frame(maxWidth: .infinity)
                    
                        Button(action: onAddTransaction) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing, 24)
                }
                .padding(.top, 128) // Increased top padding to clear the notch/dynamic island
            }
            .padding(.bottom, 100) // Extra padding for the overlapping card
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [AppTheme.primary, AppTheme.bgMain],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Overlapping Income/Expense Card
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.left.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.income)
                        Text("Pemasukan")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Text(totalIncome.formattedRupiah)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.black)
                }
                
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.expense)
                        Text("Pengeluaran")
                            .font(.subheadline)
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Text(totalExpense.formattedRupiah)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.black)
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 24)
            .offset(y: -40) // Overlap the blue background
            .padding(.bottom, -40) // Adjust layout after offset
        }
    }
}
