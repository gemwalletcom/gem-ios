// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

extension TransferData {
    public static func mock(
        type: TransferDataType = .transfer(.mock(), mode: .flexible),
        recipient: RecipientData = .mock(),
        value: BigInt = .zero
    ) -> TransferData {
        TransferData(
            type: type,
            recipientData: recipient,
            value: value
        )
    }
}
