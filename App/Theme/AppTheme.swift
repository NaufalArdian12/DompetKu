import SwiftUI

struct AppTheme {
    static let primary = Color(red: 0.063, green: 0.267, blue: 1.0) // #1044FF - Deep Royal Blue
    static let secondary = Color(red: 0.467, green: 0.651, blue: 1.0) // #77A6FF - Soft Ice Blue
    static let income = Color(red: 0.0, green: 0.596, blue: 1.0) // #0096FF - Clear Cerulean
    static let expense = Color(red: 1.0, green: 0.353, blue: 0.157) // #FF5928 - Bright Tangerine
    
    // Background Colors
    #if canImport(UIKit)
    static let uiBgMain = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0) // Soft light gray-white
    static let uiBgCard = UIColor.white
    static let bgMain = Color(uiColor: uiBgMain)
    static let bgCard = Color(uiColor: uiBgCard)
    static let bgBlueSoft = Color(red: 0.941, green: 0.965, blue: 1.0) // #F0F6FF
    #else
    static let bgMain = Color(nsColor: .windowBackgroundColor)
    static let bgCard = Color(nsColor: .controlBackgroundColor)
    static let bgBlueSoft = Color(red: 0.941, green: 0.965, blue: 1.0) // #F0F6FF
    #endif
    
    // Gradient styles
    static let primaryGradient = LinearGradient(
        colors: [primary, primary.opacity(0.10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let addTransactionGradient = LinearGradient(
        colors: [primary, income],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let balanceGradient = LinearGradient(
        colors: [Color(red: 0.07, green: 0.09, blue: 0.25), Color(red: 0.04, green: 0.05, blue: 0.14)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let incomeGradient = LinearGradient(
        colors: [income, income.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let expenseGradient = LinearGradient(
        colors: [expense, expense.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Category mapping to SF Symbols & Colors
    static func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "makanan": return "fork.knife"
        case "belanja": return "bag"
        case "hiburan": return "gamecontroller"
        case "tagihan": return "doc.plaintext"
        case "transportasi": return "car"
        case "gaji": return "dollarsign.circle"
        case "investasi": return "chart.line.uptrend.xyaxis"
        case "bonus": return "gift"
        case "sampingan": return "briefcase"
        default: return "creditcard"
        }
    }
    
    static func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "makanan": return Color.orange
        case "belanja": return Color.pink
        case "hiburan": return Color.purple
        case "tagihan": return Color.blue
        case "transportasi": return Color.teal
        case "gaji": return Color.green
        case "investasi": return Color.mint
        case "bonus": return Color.yellow
        case "sampingan": return Color.indigo
        default: return Color.gray
        }
    }
}
