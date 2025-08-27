// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemApprovalData {
    public func map() -> ApprovalData {
        return ApprovalData(
            token: self.token,
            spender: self.spender,
            value: self.value
        )
    }
}

extension ApprovalData {
    public func map() -> GemApprovalData {
        return GemApprovalData(
            token: self.token,
            spender: self.spender,
            value: self.value
        )
    }
}