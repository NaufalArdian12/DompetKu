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
                ZStack(alignment: .center) {
                    Text(currentBalance.formattedRupiah)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1).minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity)
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
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 28, height: 28)
                            .overlay(Image(systemName: "arrow.down.left").font(.caption).fontWeight(.bold).foregroundStyle(.white))
                        
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
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 28, height: 28)
                            .overlay(Image(systemName: "arrow.up.right").font(.caption).fontWeight(.bold).foregroundStyle(.white))
                        
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
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 24)
            .offset(y: -40) // Overlap the blue background
            .padding(.bottom, -40) // Adjust layout after offset
        }
    }
}
