// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct WCPairingProposal: Sendable {
    public let pairingId: String
    public let proposal: WalletConnectionSessionProposal
}

extension WCPairingProposal: Identifiable {
    public var id: String { pairingId }
}
