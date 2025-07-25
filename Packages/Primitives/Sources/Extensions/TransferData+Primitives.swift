// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public typealias TransferDataAction = ((TransferData) -> Void)?

extension TransferData {
    public func updateValue(_ newValue: BigInt) -> TransferData {
        TransferData(
            type: type,
            recipientData: recipientData,
            value: newValue
        )
    }
}
