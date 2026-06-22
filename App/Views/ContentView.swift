import SwiftUI

enum AppTab {
    case dashboard, history, analytics
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .history
    
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabBarItem(icon: "house.fill", title: "Dashboard", tab: .dashboard, selectedTab: $selectedTab)
                TabBarItem(icon: "list.bullet.rectangle.portrait.fill", title: "Riwayat", tab: .history, selectedTab: $selectedTab)
                TabBarItem(icon: "chart.pie.fill", title: "Analisis", tab: .analytics, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 10)
            .padding(.horizontal, 40)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.light)
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
