// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.GemApprovalData

public extension GemApprovalData {
    static func mock(
        token: String = "0x",
        spender: String = "0x",
        value: String = "1000000000000000000"
    ) -> GemApprovalData {
        GemApprovalData(
            token: token,
            spender: spender,
            value: value
        )
    }
}
