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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Riwayat Catatan")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                        .padding(.top, 24)
                    
                    // Custom Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        TextField("Cari kategori atau catatan...", text: $searchText)
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.92)) // Light gray pill
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    
                    // Segmented Picker
                    CustomSegmentedPicker(
                        options: FilterType.allCases,
                        title: { $0.rawValue },
                        selection: $selectedFilter
                    )
                    .padding(.horizontal)
                    
                    // Transactions Card
                    if filteredTransactions.isEmpty {
                        EmptyStateView(
                            iconName: "magnifyingglass",
                            title: "Tidak ada transaksi ditemukan",
                            message: "Coba cari kata kunci lain atau ubah filter."
                        )
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(filteredTransactions) { transaction in
                                TransactionRowView(
                                    transaction: transaction,
                                    showDivider: transaction.id != filteredTransactions.last?.id,
                                    isListRow: false
                                )
                                .swipeToDelete {
                                    transactionToDelete = transaction
                                    showingDeleteAlert = true
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.bgMain)
            .navigationBarHidden(true)
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
