import Foundation

extension Double {
    var formattedRupiah: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp "
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "Rp 0"
    }
}
