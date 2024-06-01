// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct SignMessagePayload {
    public let chain: Chain
    public let session: WalletConnectionSession
    public let wallet: Wallet
    public let message: SignMessage
    
    public init(
        chain: Chain,
        session: WalletConnectionSession,
        wallet: Wallet,
        message: SignMessage
    ) {
        self.wallet = wallet
        self.session = session
        self.chain = chain
        self.message = message
    }
}

extension SignMessagePayload: Identifiable {
    public var id: String { session.id }
}

extension WalletConnectionSessionProposal: Identifiable {
    public var id: String { metadata.url }
}
