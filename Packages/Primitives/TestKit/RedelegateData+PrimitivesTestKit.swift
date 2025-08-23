// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension RedelegateData {
    static func mock(
        delegation: Delegation = .mock(),
        toValidator: DelegationValidator = .mock()
    ) -> RedelegateData {
        RedelegateData(
            delegation: delegation,
            toValidator: toValidator
        )
    }
}