// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ReownWalletKit
import Primitives

public extension WalletConnectSign.Request {
    static func mock(
        chain: Chain = .ethereum,
        params: AnyCodable
    ) throws -> WalletConnectSign.Request {
        try WalletConnectSign.Request(
            topic: "test-topic",
            method: "test_method",
            params: params,
            chainId: chain.blockchain!
        )
    }
}
