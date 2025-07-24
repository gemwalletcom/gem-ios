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

extension TransferData: Identifiable {
    //FIX: Improve
    public var id: String { recipientData.recipient.address }
}

extension TransferDataType {
    public var shouldIgnoreValueCheck: Bool {
        switch self {
        case .transferNft, .stake, .account, .tokenApprove: true
        case .transfer, .swap, .generic: false
        }
    }

    public var canChangeValue: Bool {
        switch self {
        case let .transfer(_, isScanned): !isScanned
        case .swap: true
            // TODO: - transfer on QR canCHangeVlue false
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .redelegate: true
            case .unstake, .withdraw, .rewards: false
            }
        case .transferNft,
                .tokenApprove,
                .account,
                .generic: false
        }
    }
}
