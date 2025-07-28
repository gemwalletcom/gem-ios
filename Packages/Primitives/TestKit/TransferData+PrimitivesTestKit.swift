// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

extension TransferData {
    public static func mock(
        type: TransferDataType = .transfer(.mock()),
        recipient: RecipientData = .mock(),
        value: BigInt = .zero,
        canChangeValue: Bool = true
    ) -> TransferData {
        TransferData(
            type: type,
            recipientData: recipient,
            value: value,
            canChangeValue: canChangeValue
        )
    }
}
