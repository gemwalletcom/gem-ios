// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension TransferData {
    public static func mock(
        type: TransferDataType = .transfer(.mock()),
    ) -> Self {
        .init(
            type: type,
            recipientData: .mock(),
            value: 0,
            canChangeValue: false,
            ignoreValueCheck: false
        )
    }
}
