// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension WalletConnection: Identifiable {
    public var id: String { session.sessionId }
}

public extension WCSuiTransaction {
    var walletAddress: String {
        if let wallet = account {
            return wallet
        } else if let wallet = address {
            return wallet
        } else {
            return ""
        }
    }
}
