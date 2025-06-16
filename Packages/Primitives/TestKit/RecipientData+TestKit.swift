// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension RecipientData {
    static func mock(
        recipient: Recipient = .mock(),
        amount: String? = nil
    ) -> RecipientData {
        RecipientData(
            recipient: recipient,
            amount: amount
        )
    }
}
