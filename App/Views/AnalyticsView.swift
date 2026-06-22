import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query private var transactions: [Transaction]
    @Query private var allCategories: [TransactionCategory]
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
            let dbCat = allCategories.first { $0.name == key }
            let color = dbCat.flatMap { Color(hex: $0.colorHex) } ?? AppTheme.categoryColor(for: key)
            let icon = dbCat?.iconName ?? AppTheme.categoryIcon(for: key)
            
            return CategoryData(
                category: key,
                amount: amount,
                color: color,
                iconName: icon
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Analisis")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                        .padding(.top, 24)
                    
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
                                .padding(.top, 8)
                            
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
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedFilter)
                                .frame(height: 220)
                                
                                VStack(spacing: 2) {
                                    Text("TOTAL")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                    Text(totalForSelectedType.formattedRupiah)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .contentTransition(.numericText())
                                }
                            }
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
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(categoryData) { data in
                                    let percentage = (data.amount / totalForSelectedType) * 100
                                    
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(data.color.opacity(0.12))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Image(systemName: data.iconName)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundStyle(data.color)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(alignment: .bottom) {
                                                Text(data.category)
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                                
                                                Spacer()
                                                
                                                Text(data.amount.formattedRupiah)
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                            }
                                            
                                            HStack(spacing: 8) {
                                                // Custom Progress Bar
                                                GeometryReader { geometry in
                                                    ZStack(alignment: .leading) {
                                                        Capsule()
                                                            .fill(Color(white: 0.9))
                                                            .frame(height: 6)
                                                        
                                                        Capsule()
                                                            .fill(data.color)
                                                            .frame(width: max(0, geometry.size.width * CGFloat(percentage / 100)), height: 6)
                                                    }
                                                }
                                                .frame(height: 6)
                                                
                                                Text(String(format: "%.1f%%", percentage))
                                                    .font(.system(size: 10))
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 20)
                                    
                                    if data.id != categoryData.last?.id {
                                        Divider()
                                            .background(Color(white: 0.9))
                                            .padding(.leading, 80)
                                            .padding(.trailing, 20)
                                    }
                                }
                            }
                            .background(AppTheme.bgCard)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                            .padding(.bottom, 120) // padding for floating tab bar
                        }
                    }
                }
                .padding(.top, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollContentBackground(.hidden)
            .background(AppTheme.bgMain)
            .navigationBarHidden(true)
        }
    }
}

struct CategoryData: Identifiable, Equatable {
    var id: String { category }
    let category: String
    let amount: Double
    let color: Color
    let iconName: String
}
