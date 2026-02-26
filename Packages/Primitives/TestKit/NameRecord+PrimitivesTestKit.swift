// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension NameRecord {
    static func mock(
        name: String = "test.eth",
        chain: Chain = .ethereum,
        address: String = "0x1234567890123456789012345678901234567890",
        provider: NameProvider = .ens
    ) -> NameRecord {
        NameRecord(
            name: name,
            chain: chain,
            address: address,
            provider: provider
        )
    }
}
