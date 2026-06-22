import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            TransactionListView()
                .tabItem {
                    Label("Riwayat", systemImage: "list.bullet.rectangle.portrait.fill")
                }

            AnalyticsView()
                .tabItem {
                    Label("Analisis", systemImage: "chart.pie.fill")
                }
        }
        .tint(AppTheme.primary)
        .preferredColorScheme(.light) // Force light mode to fix text visibility
        // SwiftUI-native approach for iOS 17+ / iOS 26 (Liquid Glass):
        // sets the tab bar background to our app color and makes it visible (opaque).
        #if os(iOS)
        .toolbarBackground(AppTheme.bgMain, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        #endif
    }
}
