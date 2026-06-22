import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Tampilan")) {
                    HStack {
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
        }
    }
}
