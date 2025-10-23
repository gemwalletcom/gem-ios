// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension WalletConnection: Identifiable {
    public var id: String { session.sessionId }
}

public extension WCSuiTransaction {
    var walletAddress: String {
        return account ?? address ?? ""
    }
}
