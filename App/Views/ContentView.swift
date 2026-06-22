import SwiftUI

enum AppTab {
    case dashboard, history, analytics, settings
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var showingAddSheet = false
    
    init() {
        // Hide default tab bar if any lingering
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .history:
                    TransactionListView()
                case .analytics:
                    AnalyticsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar with Floating Action Button
            ZStack(alignment: .bottom) {
                // Background Pill
                HStack(spacing: 0) {
                    TabBarItem(icon: "house.fill", title: "Beranda", tab: .dashboard, selectedTab: $selectedTab)
                    TabBarItem(icon: "list.bullet.rectangle.portrait.fill", title: "Riwayat", tab: .history, selectedTab: $selectedTab)
                    
                    // Invisible spacer for the floating button
                    Spacer().frame(width: 64)
                    
                    TabBarItem(icon: "chart.pie.fill", title: "Analisis", tab: .analytics, selectedTab: $selectedTab)
                    TabBarItem(icon: "gearshape.fill", title: "Setelan", tab: .settings, selectedTab: $selectedTab)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 10)
                .padding(.horizontal, 20)
                
                // Floating Action Button
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.primary.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .offset(y: -24) // Float above the pill
            }
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView()
        }
    }
}

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

struct TabBarItem: View {
    let icon: String
    let title: String
    let tab: AppTab
    @Binding var selectedTab: AppTab
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(selectedTab == tab ? AppTheme.primary : .black)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(selectedTab == tab ? AppTheme.bgBlueSoft : Color.clear)
                    )
                
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(selectedTab == tab ? AppTheme.primary : .black)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
