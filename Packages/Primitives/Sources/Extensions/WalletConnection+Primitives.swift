// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension WalletConnection: Identifiable {
    public var id: String { session.sessionId }
}
extension WalletConnectionSession: Identifiable {
    public var id: String { sessionId }
}
