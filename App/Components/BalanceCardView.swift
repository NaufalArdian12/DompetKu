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
                ZStack(alignment: .top) {
                    Text("Rp 1.980.000") // Placeholder that gets replaced or just formatted
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1).minimumScaleFactor(0.6)
                        .padding(.top, 64)
                    
                    HStack {
                        Spacer()
                        Button(action: onAddTransaction) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                                .background(Circle().fill(Color.blue))
                        }
                    }
                    .padding(.top, 64)
                    .padding(.trailing, 24)
                }
            }
            .padding(.bottom, 80) // Extra padding for the overlapping card
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.6, green: 0.75, blue: 1.0), Color(white: 0.95)],
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
