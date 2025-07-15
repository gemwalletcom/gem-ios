// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Gemstone

public extension SwapperApprovalData {
    var asPrimitive: Primitives.ApprovalData {
        Primitives.ApprovalData(token: token, spender: spender, value: value)
    }
}
