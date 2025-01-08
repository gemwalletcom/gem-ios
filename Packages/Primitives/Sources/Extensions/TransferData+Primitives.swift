// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension TransferData {
    public func updateValue(_ newValue: BigInt) -> TransferData {
        TransferData(
            type: type,
            recipientData: recipientData,
            value: newValue,
            canChangeValue: canChangeValue,
            ignoreValueCheck: ignoreValueCheck
        )
    }
}

extension TransferData: Identifiable {
    //FIX: Improve
    public var id: String { recipientData.recipient.address }
}
