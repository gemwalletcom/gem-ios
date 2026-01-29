// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension ApprovalData {
    public static func mock(
        token: String = "",
        spender: String = "",
        value: String = ""
    ) -> ApprovalData {
        ApprovalData(token: token, spender: spender, value: value)
    }
}
