import Foundation
import SwiftData
import SwiftUI

@Model
class Wallet {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var initialBalance: Double
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, iconName: String, colorHex: String, initialBalance: Double = 0, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.initialBalance = initialBalance
        self.isDefault = isDefault
    }
}
