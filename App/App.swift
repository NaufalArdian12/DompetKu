import SwiftUI
import SwiftData

@main
struct DompetkuApp: App {
    @StateObject private var lockManager = AppLockManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                if lockManager.isUnlocked {
                    ContentView()
                        .environmentObject(lockManager)
                } else {
                    VStack(spacing: 24) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(AppTheme.primary)
                        Text("Dompetku Terkunci")
                            .font(.title.weight(.bold))
                        Text("Gunakan Face ID atau PIN Anda untuk masuk.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button(action: {
                            lockManager.authenticate()
                        }) {
                            Text("Buka Kunci")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(AppTheme.primary)
                                .cornerRadius(25)
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.bgMain)
                }
            }
            .onAppear {
                lockManager.authenticate()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    lockManager.lockApp()
                } else if newPhase == .active && !lockManager.isUnlocked {
                    lockManager.authenticate()
                }
            }
        }
        .modelContainer(for: [Transaction.self, TransactionCategory.self]) { result in
            switch result {
            case .success(let container):
                let context = container.mainContext
                let descriptor = FetchDescriptor<TransactionCategory>()
                if (try? context.fetchCount(descriptor)) == 0 {
                    // Seed default categories
                    let defaults = [
                        TransactionCategory(name: "Makanan", iconName: "fork.knife", colorHex: "#34C759", type: .expense, isDefault: true),
                        TransactionCategory(name: "Belanja", iconName: "cart.fill", colorHex: "#007AFF", type: .expense, isDefault: true),
                        TransactionCategory(name: "Transportasi", iconName: "car.fill", colorHex: "#FF9500", type: .expense, isDefault: true),
                        TransactionCategory(name: "Hiburan", iconName: "tv.fill", colorHex: "#AF52DE", type: .expense, isDefault: true),
                        TransactionCategory(name: "Gaji", iconName: "dollarsign.circle.fill", colorHex: "#34C759", type: .income, isDefault: true),
                        TransactionCategory(name: "Investasi", iconName: "chart.line.uptrend.xyaxis", colorHex: "#007AFF", type: .income, isDefault: true),
                        TransactionCategory(name: "Lainnya", iconName: "ellipsis.circle.fill", colorHex: "#8E8E93", type: .expense, isDefault: true)
                    ]
                    for cat in defaults {
                        context.insert(cat)
                    }
                }
            case .failure(let error):
                print("Failed to create container: \(error)")
            }
        }
    }
}
