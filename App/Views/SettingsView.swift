import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("isFaceIDEnabled") private var isFaceIDEnabled: Bool = false
    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 0.0
    
    @State private var budgetString: String = ""
    
    @Query private var transactions: [Transaction]
    @State private var csvDocument: CSVDocument?
    @State private var isExporting = false
    
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
                
                Section(header: Text("Dompet & Kategori")) {
                    NavigationLink(destination: WalletSettingsView()) {
                        HStack {
                            Image(systemName: "wallet.pass.fill")
                                .foregroundStyle(AppTheme.primary)
                            Text("Kelola Dompet / Rekening")
                        }
                    }
                    
                    NavigationLink(destination: CategorySettingsView()) {
                        HStack {
                            Image(systemName: "square.grid.2x2.fill")
                                .foregroundStyle(AppTheme.primary)
                            Text("Kelola Kategori Kustom")
                        }
                    }
                }
                
                Section(header: Text("Data & Ekspor")) {
                    Button(action: generateCSV) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundStyle(AppTheme.primary)
                            Text("Ekspor Riwayat ke CSV")
                                .foregroundStyle(.primary)
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
            .fileExporter(
                isPresented: $isExporting,
                document: csvDocument,
                contentType: .commaSeparatedText,
                defaultFilename: "Dompetku_Riwayat_\(Date().formatted(date: .numeric, time: .omitted)).csv"
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print("Export failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func generateCSV() {
        var csvString = "Tanggal,Kategori,Tipe,Nominal,Catatan\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for tx in transactions {
            let date = formatter.string(from: tx.date)
            let type = tx.type == .income ? "Pemasukan" : "Pengeluaran"
            // escape quotes in note if any
            let note = tx.note.replacingOccurrences(of: "\"", with: "\"\"")
            
            let row = "\(date),\(tx.category),\(type),\(tx.amount),\"\(note)\"\n"
            csvString.append(row)
        }
        
        csvDocument = CSVDocument(text: csvString)
        isExporting = true
    }
}

import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var text: String
    
    init(text: String = "") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            text = string
        } else {
            text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
