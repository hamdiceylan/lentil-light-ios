//
//  UserManager.swift
//  qrcode
//
//  Created by David Goncalves on 24/07/2018.
//  Copyright © 2018 TinyLab. All rights reserved.
//

import UIKit
import RevenueCat

class UserManager: NSObject {
    
    private static let kUserPremiumKey = "USER_PREMIUM"
    
    static let shared = UserManager()
    
    var premium = UserDefaults.standard.bool(forKey: UserManager.kUserPremiumKey) {
        didSet {
            UserDefaults.standard.set(premium, forKey: UserManager.kUserPremiumKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                print("RC getCustomerInfo error: \(error.localizedDescription)")
                return
            }
            
            guard let info = customerInfo else { return }
            
            // Entitlement Check
            let premiumActive = info.entitlements["Premium"]?.isActive == true
            
            DispatchQueue.main.async {
                self.premium = premiumActive
            }
        }
    }
    
}
