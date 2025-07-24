// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public typealias TransferDataAction = ((TransferData) -> Void)?

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

extension TransferDataType {
    public var shouldIgnoreValueCheck: Bool {
        switch self {
        case .transferNft, .stake, .account, .tokenApprove: true
        case .transfer, .deposit, .swap, .generic: false
        }
    }
}
