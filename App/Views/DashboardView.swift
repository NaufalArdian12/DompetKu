import SwiftUI
import SwiftData
import Charts
#if canImport(UIKit)
import UIKit
#endif

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var showingAddSheet = false
    @State private var transactionToDelete: Transaction?
    @State private var showingDeleteAlert = false
    
    @Query(sort: \Wallet.name) private var wallets: [Wallet]
    @State private var selectedWalletId: UUID? = nil // nil means "Semua"
    
    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 0.0
    
    private var filteredTransactions: [Transaction] {
        if let selectedWalletId {
            return transactions.filter { $0.walletId == selectedWalletId }
        }
        return transactions
    }
    
    // Financial Calculations
    private var currentMonthExpense: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        return filteredTransactions.filter { $0.type == .expense && $0.date >= startOfMonth }.reduce(0) { $0 + $1.amount }
    }
    private var totalIncome: Double {
        filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    private var currentBalance: Double {
        if let selectedWalletId, let wallet = wallets.first(where: { $0.id == selectedWalletId }) {
            return wallet.initialBalance
        }
        // If "Semua", sum all initial balances
        let baseBalance = wallets.reduce(0) { $0 + $1.initialBalance }
        // If we want actual balance, should it be baseBalance?
        // Wait, initialBalance is currently being updated in AddTransactionView as the current balance.
        // So initialBalance is actually the running balance! Let's rename in mind to currentBalance.
        return baseBalance
    }
    
    // Daily Summary logic for the 7-day SwiftChart
    private var dailySummaries: [DailySummary] {
        let calendar = Calendar.current
        let now = Date()
        var summaries: [DailySummary] = []
        
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let dailyTransactions = filteredTransactions.filter { $0.date >= startOfDay && $0.date < endOfDay }
                let dailyIncome = dailyTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
                let dailyExpense = dailyTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
                
                summaries.append(DailySummary(date: startOfDay, income: dailyIncome, expense: dailyExpense))
            }
        }
        return summaries
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    

                    
                    BalanceCardView(
                        currentBalance: currentBalance,
                        totalIncome: totalIncome,
                        totalExpense: totalExpense,
                        onAddTransaction: {
                            showingAddSheet = true
                        }
                    )
                    
                    // Wallet Selector
                    if !wallets.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                walletPill(title: "Semua Dompet", icon: "square.stack.3d.up.fill", isSelected: selectedWalletId == nil) {
                                    withAnimation { selectedWalletId = nil }
                                }
                                ForEach(wallets) { wallet in
                                    walletPill(title: wallet.name, icon: wallet.iconName, isSelected: selectedWalletId == wallet.id) {
                                        withAnimation { selectedWalletId = wallet.id }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                    }
                    
                    // Budget Section
                    if monthlyBudget > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Anggaran Bulan Ini")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.black)
                                Spacer()
                                Text(currentMonthExpense.formattedRupiah + " / " + monthlyBudget.formattedRupiah)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 12)
                                    
                                    Capsule()
                                        .fill(currentMonthExpense > monthlyBudget ? Color.red : AppTheme.primary)
                                        .frame(width: min(geometry.size.width * CGFloat(currentMonthExpense / monthlyBudget), geometry.size.width), height: 12)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentMonthExpense)
                                }
                            }
                            .frame(height: 12)
                            
                            if currentMonthExpense > monthlyBudget {
                                Text("Peringatan: Pengeluaran bulan ini telah melewati batas!")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding()
                        .background(AppTheme.bgCard)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                    }
                    
                    // Chart Section (7 Days Trend)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tren Keuangan (7 Hari)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                        
                        if transactions.isEmpty {
                            EmptyStateView(
                                iconName: "chart.bar.xaxis",
                                title: "Belum ada data untuk grafik",
                                message: ""
                            )
                            .frame(height: 180)
                            .background(AppTheme.bgCard)
                            .cornerRadius(16)
                        } else {
                            VStack {
                                Chart {
                                    ForEach(dailySummaries) { summary in
                                        BarMark(
                                            x: .value("Hari", summary.date, unit: .day),
                                            y: .value("Jumlah", summary.income)
                                        )
                                        .foregroundStyle(AppTheme.income.gradient)
                                        .position(by: .value("Tipe", "Pemasukan"))
                                        
                                        BarMark(
                                            x: .value("Hari", summary.date, unit: .day),
                                            y: .value("Jumlah", summary.expense)
                                        )
                                        .foregroundStyle(AppTheme.expense.gradient)
                                        .position(by: .value("Tipe", "Pengeluaran"))
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { value in
                                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                    }
                                }
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dailySummaries)
                                .frame(height: 180)
                                .padding(.top, 10)
                                
                                // Legend
                                HStack(spacing: 20) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(AppTheme.income)
                                            .frame(width: 8, height: 8)
                                        Text("Pemasukan").font(.caption).foregroundStyle(.secondary)
                                    }
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(AppTheme.expense)
                                            .frame(width: 8, height: 8)
                                        Text("Pengeluaran").font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .padding()
                            .background(AppTheme.bgCard)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Transactions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Transactions")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.black)
                            Spacer()
                            Text("See all")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal)
                        
                        if transactions.isEmpty {
                            EmptyStateView(
                                iconName: "tray",
                                title: "Belum Ada Transaksi",
                                message: "Mulai catat pengeluaran atau pemasukan pertama Anda!"
                            )
                            .background(AppTheme.bgCard)
                            .cornerRadius(16)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(transactions.prefix(5)) { transaction in
                                    TransactionRowView(
                                        transaction: transaction,
                                        showDivider: transaction.id != transactions.prefix(5).last?.id,
                                        isListRow: false
                                    )
                                    .swipeToDelete {
                                        transactionToDelete = transaction
                                        showingDeleteAlert = true
                                        #if os(iOS)
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        #endif
                                    }
                                }
                            }
                            .background(AppTheme.bgCard)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.02), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.bottom, 120) // padding to clear floating tab bar
            }
            .ignoresSafeArea(edges: .top)
            .scrollContentBackground(.hidden)
            .background(AppTheme.bgMain)
            // .navigationTitle("Dompetku")
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .alert("Hapus Transaksi", isPresented: $showingDeleteAlert, presenting: transactionToDelete) { transaction in
                Button("Hapus", role: .destructive) {
                    modelContext.delete(transaction)
                    transactionToDelete = nil
                }
                Button("Batal", role: .cancel) {
                    transactionToDelete = nil
                }
            } message: { transaction in
                Text("Apakah Anda yakin ingin menghapus transaksi \(transaction.category) senilai \(transaction.formattedAmount)?")
            }
        }
    }
    
    private func walletPill(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.primary : AppTheme.bgCard)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? AppTheme.primary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// Model helper for the chart
struct DailySummary: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let income: Double
    let expense: Double
}
