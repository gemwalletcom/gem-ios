// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension BannerAction {
    var closeOnAction: Bool {
        switch event {
        case .stake,
             .accountActivation,
             .accountBlockedMultiSignature,
             .activateAsset,
             .suspiciousAsset: false
        case .enableNotifications: true
        }
    }
}
