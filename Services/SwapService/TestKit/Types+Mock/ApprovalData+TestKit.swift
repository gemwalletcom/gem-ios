// Copyright (c). Gem Wallet. All rights reserved.

import struct Gemstone.ApprovalData

extension ApprovalData {
    static func mock() -> ApprovalData {
        ApprovalData(
            token: "0x",
            spender: "0x",
            value: "1000000000000000000"
        )
    }}
