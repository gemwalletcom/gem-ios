// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesTestKit
import WalletConnectorService
import struct Gemstone.SignMessage

public extension SignMessagePayload {
    static func mock(
        chain: Chain = .ethereum,
        session: WalletConnectionSession = .mock(),
        wallet: Wallet = .mock(),
        message: SignMessage = SignMessage(chain: "ethereum", signType: .eip191, data: Data())
    ) -> SignMessagePayload {
        SignMessagePayload(
            chain: chain,
            session: session,
            wallet: wallet,
            message: message
        )
    }
}
