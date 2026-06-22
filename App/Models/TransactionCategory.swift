import Foundation
import SwiftData

@Model
class TransactionCategory {
    var id: UUID = UUID()
    var name: String
    var iconName: String
    var colorHex: String
    var typeString: String
    var isDefault: Bool
    
    @Transient
    var type: TransactionType {
        get { TransactionType(rawValue: typeString) ?? .expense }
        set { typeString = newValue.rawValue }
    }
    
    init(name: String, iconName: String, colorHex: String, type: TransactionType, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.typeString = type.rawValue
        self.isDefault = isDefault
    }
}
