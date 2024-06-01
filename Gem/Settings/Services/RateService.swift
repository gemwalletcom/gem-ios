// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import StoreKit

struct RateService {
    
    let preferences: Preferences = .standard

    func perform() {
        #if DEBUG
        #else
        if preferences.launchesCount >= 15 && !preferences.rateApplicationShown {
            rate()
            preferences.rateApplicationShown = true
        }
        #endif
    }
    
    func rate() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}
