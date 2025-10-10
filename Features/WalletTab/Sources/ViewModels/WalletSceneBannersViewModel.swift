// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct WalletSceneBannersViewModel: Sendable {
    let banners: [Banner]
    let totalFiatValue: Double

    var allBanners: [Banner] {
        banners
            .filter(shouldShowBanner)
            .sorted { $0 < $1 }
    }
    
    // MARK: - Private

    private func shouldShowBanner(_ banner: Banner) -> Bool {
        switch banner.event {
        case .accountActivation, .accountBlockedMultiSignature, .enableNotifications: true
        case .stake, .activateAsset, .suspiciousAsset: false
        case .onboarding: totalFiatValue.isZero
        }
    }
}
