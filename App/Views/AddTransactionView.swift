import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \TransactionCategory.name) private var allCategories: [TransactionCategory]
    @Query(sort: \Wallet.name) private var wallets: [Wallet]
    
    @State private var amountString = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory = "Makanan"
    @State private var selectedWalletId: UUID? = nil
    @State private var date = Date()
    @State private var note = ""
    @State private var isRecurring = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @FocusState private var isAmountFocused: Bool
    
    var categories: [TransactionCategory] {
        allCategories.filter { $0.type == selectedType }
    }
    
    private var parsedAmount: Double? {
        let unformattedString = amountString.replacingOccurrences(of: ".", with: "")
        return Double(unformattedString)
    }
    
    private var canSave: Bool {
        guard let parsedAmount else { return false }
        return parsedAmount > 0
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        amountEntrySection
                        transactionTypeSection
                        categorySection
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedType)
                        walletSection
                        detailsSection
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 96)
                }
                .scrollContentBackground(.hidden)
                
                saveButtonSection
            }
            .background(AppTheme.bgMain)
            .navigationTitle("Tambah Catatan")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isAmountFocused = true
                if selectedWalletId == nil {
                    selectedWalletId = wallets.first?.id
                }
            }
        }
    }
    
    private var amountEntrySection: some View {
        VStack(spacing: 10) {
            Text("Jumlah Uang")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Rp")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.92))
                
                TextField("0", text: $amountString)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .focused($isAmountFocused)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .onChange(of: amountString) { oldValue, newValue in
                        formatAmount(oldValue: oldValue, newValue: newValue)
                    }
            }
            
            Text("Masukkan nominal transaksi")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(AppTheme.addTransactionGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.primary.opacity(0.18), radius: 18, x: 0, y: 10)
        .padding(.horizontal)
    }
    
    private var transactionTypeSection: some View {
        Picker("Tipe", selection: $selectedType) {
            Text("Keluar").tag(TransactionType.expense)
            Text("Masuk").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .padding(4)
        .background(AppTheme.bgBlueSoft)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
        .onChange(of: selectedType) { _, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = newValue == .expense ? "Makanan" : "Gaji"
            }
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategori")
                .font(.headline)
                .foregroundStyle(.black)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryButton(for: category)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func categoryButton(for category: TransactionCategory) -> some View {
        let isSelected = selectedCategory == category.name
        let catColor = Color(hex: category.colorHex) ?? AppTheme.primary
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedCategory = category.name
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : catColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? catColor : catColor.opacity(0.15))
                    )
                
                Text(category.name)
                    .font(.caption.weight(isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? catColor : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.bgCard)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? catColor : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: isSelected ? catColor.opacity(0.12) : .black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var walletSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dompet / Rekening")
                .font(.headline)
                .foregroundStyle(.black)
            
            if !wallets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(wallets) { wallet in
                            walletButton(for: wallet)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func walletButton(for wallet: Wallet) -> some View {
        let isSelected = selectedWalletId == wallet.id || (selectedWalletId == nil && wallet.isDefault)
        let wColor = Color(hex: wallet.colorHex) ?? AppTheme.primary
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedWalletId = wallet.id
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: wallet.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : wColor)
                
                Text(wallet.name)
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? wColor : wColor.opacity(0.1))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : wColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var detailsSection: some View {
        VStack(spacing: 16) {
            DatePicker("Tanggal", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
            
            Divider()
            
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(AppTheme.primary)
                TextField("Catatan tambahan...", text: $note)
            }
            
            Divider()
            
            Toggle(isOn: $isRecurring.animation()) {
                HStack {
                    Image(systemName: "arrow.2.squarepath")
                        .foregroundStyle(AppTheme.primary)
                    Text("Jadikan Rutin")
                }
            }
            
            if isRecurring {
                Picker("Frekuensi", selection: $recurringFrequency) {
                    ForEach(RecurringFrequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private var saveButtonSection: some View {
        Button(action: saveTransaction) {
            Text("Simpan Transaksi")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(canSave ? AppTheme.primary : Color.gray.opacity(0.35))
                )
        }
        .disabled(!canSave)
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }
    
    private func formatAmount(oldValue: String, newValue: String) {
        let unformatted = newValue.replacingOccurrences(of: ".", with: "")
                                  .replacingOccurrences(of: ",", with: "")
        
        // Filter out any non-digit characters to prevent crashes or infinite loops
        let digitsOnly = unformatted.filter { $0.isNumber }
        
        if let number = Int(digitsOnly) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            formatter.maximumFractionDigits = 0
            
            if let formatted = formatter.string(from: NSNumber(value: number)), amountString != formatted {
                amountString = formatted
            }
        } else if digitsOnly.isEmpty {
            if amountString != "" {
                amountString = ""
            }
        } else {
            amountString = oldValue
        }
    }
    
    private func saveTransaction() {
        guard let amount = parsedAmount, amount > 0 else { return }
        
        let transaction = Transaction(
            amount: amount,
            type: selectedType,
            category: selectedCategory,
            date: date,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            walletId: selectedWalletId
        )
        
        modelContext.insert(transaction)
        
        // Update wallet balance if a wallet is selected
        if let wId = selectedWalletId, let wallet = wallets.first(where: { $0.id == wId }) {
            if selectedType == .income {
                wallet.initialBalance += amount
            } else {
                wallet.initialBalance -= amount
            }
        }
        
        // Save recurring transaction if toggled
        if isRecurring {
            let nextDate = recurringFrequency.nextDate(from: date)
            let recurringTx = RecurringTransaction(
                amount: amount,
                type: selectedType,
                category: selectedCategory,
                walletId: selectedWalletId,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                frequency: recurringFrequency,
                nextFireDate: nextDate
            )
            modelContext.insert(recurringTx)
        }
        
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        
        dismiss()
    }
}
