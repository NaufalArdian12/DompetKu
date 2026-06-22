import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var searchText = ""
    @State private var selectedFilter: FilterType = .all
    @State private var transactionToDelete: Transaction?
    @State private var showingDeleteAlert = false
    
    enum FilterType: String, CaseIterable {
        case all = "Semua"
        case income = "Pemasukan"
        case expense = "Pengeluaran"
    }
    
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            // Search text filter
            let matchesSearch = searchText.isEmpty || 
                transaction.category.localizedCaseInsensitiveContains(searchText) || 
                transaction.note.localizedCaseInsensitiveContains(searchText)
            
            // Type filter
            let matchesType: Bool
            switch selectedFilter {
            case .all:
                matchesType = true
            case .income:
                matchesType = transaction.type == .income
            case .expense:
                matchesType = transaction.type == .expense
            }
            
            return matchesSearch && matchesType
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CustomSegmentedPicker(
                    options: FilterType.allCases,
                    title: { $0.rawValue },
                    selection: $selectedFilter
                )
                .padding()
                .background(AppTheme.bgMain)
                
                // Transactions List
                if filteredTransactions.isEmpty {
                    EmptyStateView(
                        iconName: "magnifyingglass",
                        title: "Tidak ada transaksi ditemukan",
                        message: "Coba cari kata kunci lain atau ubah filter."
                    )
                    .background(AppTheme.bgMain)
                    .background(AppTheme.bgMain)
                } else {
                    List {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRowView(
                                transaction: transaction,
                                showDivider: false, // List style provides its own separators if needed, or we use cards
                                isListRow: true
                            )
                            .listRowBackground(AppTheme.bgCard)
                        }
                        .onDelete { offsets in
                            if let index = offsets.first {
                                transactionToDelete = filteredTransactions[index]
                                showingDeleteAlert = true
                            }
                        }
                    }
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    #else
                    .listStyle(.inset)
                    #endif
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.bgMain)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.bgMain)
            .navigationTitle("Riwayat Catatan")
            // SwiftUI-native navigation bar background for iOS 17+ / iOS 26
            #if os(iOS)
            .toolbarBackground(AppTheme.bgMain, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
            .searchable(text: $searchText, prompt: "Cari kategori atau catatan...")
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
}
