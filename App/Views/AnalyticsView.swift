import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query private var transactions: [Transaction]
    @State private var selectedFilter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "Semua"
        case income = "Pemasukan"
        case expense = "Pengeluaran"
    }
    
    private var filteredTransactions: [Transaction] {
        switch selectedFilter {
        case .all: return transactions
        case .income: return transactions.filter { $0.type == .income }
        case .expense: return transactions.filter { $0.type == .expense }
        }
    }
    
    private var totalForSelectedType: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private var categoryData: [CategoryData] {
        let typeTransactions = filteredTransactions
        let total = typeTransactions.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }
        
        let grouped = Dictionary(grouping: typeTransactions, by: { $0.category })
        
        return grouped.map { (key, value) in
            let amount = value.reduce(0) { $0 + $1.amount }
            return CategoryData(
                category: key,
                amount: amount,
                color: AppTheme.categoryColor(for: key)
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Segmented Picker
                    CustomSegmentedPicker(
                        options: FilterType.allCases,
                        title: { $0.rawValue },
                        selection: $selectedFilter
                    )
                    .padding(.horizontal)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedFilter)
                    
                    if categoryData.isEmpty {
                        EmptyStateView(
                            iconName: "chart.pie.fill",
                            title: "Belum ada data analisis",
                            message: "Catat beberapa transaksi terlebih dahulu untuk melihat diagram distribusi kategori."
                        )
                        .frame(height: 350)
                    } else {
                        // Donut Chart Card
                        VStack(spacing: 16) {
                            Text("Distribusi " + selectedFilter.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ZStack {
                                Chart(categoryData) { item in
                                    SectorMark(
                                        angle: .value("Jumlah", item.amount),
                                        innerRadius: .ratio(0.65),
                                        angularInset: 2.0
                                    )
                                    .cornerRadius(6)
                                    .foregroundStyle(item.color)
                                }
                                .frame(height: 220)
                                
                                VStack(spacing: 2) {
                                    Text("Total")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                    Text(totalForSelectedType.formattedRupiah)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .contentTransition(.numericText())
                                }
                            }
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedFilter)
                        }
                        .padding()
                        .background(AppTheme.bgCard)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        // Category Breakdowns List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Detail Kategori")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(categoryData) { data in
                                    let percentage = (data.amount / totalForSelectedType) * 100
                                    
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(data.color.opacity(0.12))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: AppTheme.categoryIcon(for: data.category))
                                                    .font(.footnote)
                                                    .foregroundStyle(data.color)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(data.category)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            ProgressView(value: percentage, total: 100)
                                                .tint(data.color)
                                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text(data.amount.formattedRupiah)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                            Text(String(format: "%.1f%%", percentage))
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    
                                    if data.id != categoryData.last?.id {
                                        Divider().padding(.leading, 64)
                                    }
                                }
                            }
                            .background(AppTheme.bgCard)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.02), radius: 6, x: 0, y: 3)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.bgMain)
            .navigationTitle("Analisis")
            // SwiftUI-native navigation bar background for iOS 17+ / iOS 26
            #if os(iOS)
            .toolbarBackground(AppTheme.bgMain, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
        }
    }
}

struct CategoryData: Identifiable, Equatable {
    var id: String { category }
    let category: String
    let amount: Double
    let color: Color
}
