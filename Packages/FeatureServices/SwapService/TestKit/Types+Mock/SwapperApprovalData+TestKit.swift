// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.GemApprovalData

public extension GemApprovalData {
    static func mock() -> GemApprovalData {
        GemApprovalData(
            token: "0x",
            spender: "0x",
            value: "1000000000000000000"
        )
    }
}
