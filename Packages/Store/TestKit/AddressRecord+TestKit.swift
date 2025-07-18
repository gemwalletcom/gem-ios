// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public extension AddressRecord {
    static func mock(
        chain: Chain = .ethereum,
        address: String = "0x742d35cc6327c516e07e17dddaef8b48ca1e8c4a",
        name: String = "Hyperliquid"
    ) -> AddressRecord {
        AddressRecord(
            chain: chain,
            address: address,
            name: name
        )
    }
}