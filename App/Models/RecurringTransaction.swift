import Foundation
import SwiftData

@Model
class RecurringTransaction {
    var id: UUID
    var amount: Double
    var typeString: String
    var category: String
    var walletId: UUID?
    var note: String
    var frequencyString: String
    var nextFireDate: Date
    
    init(id: UUID = UUID(), amount: Double, type: TransactionType, category: String, walletId: UUID? = nil, note: String = "", frequency: RecurringFrequency, nextFireDate: Date) {
        self.id = id
        self.amount = amount
        self.typeString = type.rawValue
        self.category = category
        self.walletId = walletId
        self.note = note
        self.frequencyString = frequency.rawValue
        self.nextFireDate = nextFireDate
    }
    
    @Transient
    var type: TransactionType {
        get { TransactionType(rawValue: typeString) ?? .expense }
        set { typeString = newValue.rawValue }
    }
    
    @Transient
    var frequency: RecurringFrequency {
        get { RecurringFrequency(rawValue: frequencyString) ?? .monthly }
        set { frequencyString = newValue.rawValue }
    }
}

enum RecurringFrequency: String, Codable, CaseIterable {
    case daily = "Harian"
    case weekly = "Mingguan"
    case monthly = "Bulanan"
    case yearly = "Tahunan"
    
    func nextDate(from current: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: current) ?? current
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: current) ?? current
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: current) ?? current
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: current) ?? current
        }
    }
}
