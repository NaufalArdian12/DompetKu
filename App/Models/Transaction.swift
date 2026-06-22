import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var typeString: String = "expense" // "income" or "expense"
    var category: String
    var date: Date
    var note: String
    
    init(id: UUID = UUID(), amount: Double, type: TransactionType, category: String, date: Date = Date(), note: String = "") {
        self.id = id
        self.amount = amount
        self.typeString = type.rawValue
        self.category = category
        self.date = date
        self.note = note
    }
    
    @Transient
    var type: TransactionType {
        get { TransactionType(rawValue: typeString) ?? .expense }
        set { typeString = newValue.rawValue }
    }
    
    var formattedAmount: String {
        let doubleAmount: Double = amount
        return doubleAmount.formattedRupiah
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"
    
    var localizedName: String {
        switch self {
        case .income: return "Pemasukan"
        case .expense: return "Pengeluaran"
        }
    }
}
