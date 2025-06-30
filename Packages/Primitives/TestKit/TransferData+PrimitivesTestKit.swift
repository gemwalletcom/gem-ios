// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

extension TransferData {
    public static func mock(
        type: TransferDataType = .transfer(.mock()),
        value: BigInt = .zero
    ) -> Self {
        .init(
            type: type,
            recipientData: .mock(),
            value: value,
            canChangeValue: false,
            ignoreValueCheck: false
        )
    }
}
