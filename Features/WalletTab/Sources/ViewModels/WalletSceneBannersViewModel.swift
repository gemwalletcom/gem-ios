// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct WalletSceneBannersViewModel: Sendable {
    let banners: [Banner]
    let totalFiatValue: Double
    
    var priorityBanner: Banner? {
        visibleBanners.first
    }

    var visibleBanners: [Banner] {
        banners
            .filter(shouldDisplay)
            .sorted { $0 < $1 }
    }
    
    // MARK: - Private

    private func shouldDisplay(_ banner: Banner) -> Bool {
        switch banner.event {
        case .stake, .activateAsset, .suspiciousAsset: false
        case .accountActivation, .accountBlockedMultiSignature, .enableNotifications: true
        case .onboarding: totalFiatValue.isZero
        }
    }
}
