// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.SwapperApprovalData

public extension SwapperApprovalData {
    static func mock() -> SwapperApprovalData {
        SwapperApprovalData(
            token: "0x",
            spender: "0x",
            value: "1000000000000000000"
        )
    }
}
