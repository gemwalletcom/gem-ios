// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

extension TransferData {
    public static func mock(
        type: TransferDataType = .transfer(.mock()),
        value: BigInt = .zero,
        recipientData: RecipientData = .mock()
    ) -> Self {
        .init(
            type: type,
            recipientData: recipientData,
            value: value,
            canChangeValue: false,
            ignoreValueCheck: type.shouldIgnoreValueCheck
        )
    }
}
