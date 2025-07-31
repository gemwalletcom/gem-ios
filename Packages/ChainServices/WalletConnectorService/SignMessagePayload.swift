// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import struct Gemstone.SignMessage

public struct SignMessagePayload: Sendable {
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
