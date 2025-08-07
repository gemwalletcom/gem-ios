// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

extension TransferData {
    public static func mock(
        type: TransferDataType = .transfer(.mock()),
        recipientData: RecipientData = .mock(),
        value: BigInt = .zero,
        canChangeValue: Bool = true
    ) -> TransferData {
        TransferData(
            type: type,
            recipientData: recipientData,
            value: value,
            canChangeValue: canChangeValue
        )
    }
}
