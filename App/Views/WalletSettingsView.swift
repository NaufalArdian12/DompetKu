import SwiftUI
import SwiftData

struct WalletSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Wallet.name) private var wallets: [Wallet]
    
    @State private var showingAddWallet = false
    
    var body: some View {
        List {
            ForEach(wallets) { wallet in
                HStack(spacing: 16) {
                    let wColor = Color(hex: wallet.colorHex) ?? AppTheme.primary
                    Image(systemName: wallet.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(wColor)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(wallet.name)
                            .font(.headline)
                        Text(wallet.isDefault ? "Dompet Utama" : "Dompet Tambahan")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .swipeActions(edge: .trailing) {
                    if !wallet.isDefault {
                        Button(role: .destructive) {
                            modelContext.delete(wallet)
                        } label: {
                            Label("Hapus", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Dompet & Rekening")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddWallet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddWallet) {
            AddWalletView()
        }
    }
}

struct AddWalletView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var colorHex = "#007AFF"
    @State private var iconName = "tray.full.fill"
    
    let icons = ["tray.full.fill", "creditcard.fill", "building.columns.fill", "wallet.pass.fill", "briefcase.fill", "case.fill"]
    let colors = ["#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#00C7BE", "#32ADE6", "#007AFF", "#5856D6", "#AF52DE", "#FF2D55"]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nama Dompet (Contoh: BCA, GoPay)", text: $name)
                
                Section(header: Text("Warna")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex) ?? .gray)
                                    .frame(width: 40, height: 40)
                                    .overlay(Circle().stroke(Color.black, lineWidth: colorHex == hex ? 2 : 0))
                                    .onTapGesture { colorHex = hex }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Ikon")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title)
                                    .frame(width: 44, height: 44)
                                    .background(iconName == icon ? Color(hex: colorHex)?.opacity(0.3) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .onTapGesture { iconName = icon }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Dompet Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        let newWallet = Wallet(name: name, iconName: iconName, colorHex: colorHex, isDefault: false)
                        modelContext.insert(newWallet)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
