import SwiftUI

struct SettingsView: View {
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 0.0
    
    @State private var budgetString: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Keamanan")) {
                    HStack {
                        Image(systemName: "faceid")
                            .foregroundStyle(AppTheme.primary)
                        Toggle("Gunakan Face ID / Touch ID", isOn: $isFaceIDEnabled)
                    }
                }
                
                Section(header: Text("Kategori")) {
                    NavigationLink(destination: CategorySettingsView()) {
                        HStack {
                            Image(systemName: "square.grid.2x2.fill")
                                .foregroundStyle(AppTheme.primary)
                            Text("Kelola Kategori Kustom")
                        }
                    }
                }
                
                Section(header: Text("Anggaran Bulanan"), footer: Text("Atur batas maksimal pengeluaran bulanan Anda untuk memonitor keuangan di Dashboard.")) {
                    HStack {
                        Text("Rp")
                            .foregroundStyle(.gray)
                        TextField("0", text: $budgetString)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .onChange(of: budgetString) { oldValue, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue {
                                    budgetString = filtered
                                }
                                monthlyBudget = Double(filtered) ?? 0.0
                            }
                    }
                }
                
                Section(header: Text("Tampilan")) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(AppTheme.primary)
                        Text("Tema Gelap")
                        Spacer()
                        Toggle("", isOn: .constant(false))
                            .labelsHidden()
                    }
                }
                
                Section(header: Text("Tentang")) {
                    HStack {
                        Text("Versi Aplikasi")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .navigationTitle("Pengaturan")
            .background(AppTheme.bgMain)
            .scrollContentBackground(.hidden)
            .onAppear {
                if monthlyBudget > 0 {
                    budgetString = String(format: "%.0f", monthlyBudget)
                }
            }
        }
    }
}
