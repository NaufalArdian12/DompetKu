import SwiftUI
import SwiftData

@main
struct DompetkuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Transaction.self)
    }
}
