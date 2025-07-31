// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.Permit2ApprovalData

public extension Permit2ApprovalData {
    static func mock() -> Permit2ApprovalData {
        Permit2ApprovalData(
            token: "0x",
            spender: "0x",
            value: "1000000000000000000",
            permit2Contract: "0x",
            permit2Nonce: 123456789
        )
    }
}
