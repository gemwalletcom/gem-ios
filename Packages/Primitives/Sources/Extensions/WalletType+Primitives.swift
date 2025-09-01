// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension WalletType {
    var isWatchOnly: Bool {
        switch self {
        case .multicoin, .single, .privateKey: false
        case .view: true
        }
    }
}
