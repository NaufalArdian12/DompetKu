import Foundation
import LocalAuthentication
import SwiftUI

class AppLockManager: ObservableObject {
    @Published var isUnlocked: Bool = false
    @AppStorage("isFaceIDEnabled") var isFaceIDEnabled: Bool = false
    
    func authenticate() {
        guard isFaceIDEnabled else {
            isUnlocked = true
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Buka kunci untuk melihat catatan keuangan") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // Keep locked
                        self.isUnlocked = false
                    }
                }
            }
        } else {
            // No biometrics available, allow entry or ask for passcode
            isUnlocked = true
        }
    }
    
    func lockApp() {
        if isFaceIDEnabled {
            isUnlocked = false
        }
    }
}
