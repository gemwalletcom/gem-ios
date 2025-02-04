// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferData: Sendable, Hashable {
    public let type: TransferDataType
    public let recipientData: RecipientData
    public let value: BigInt
    public let canChangeValue: Bool
    public let ignoreValueCheck: Bool

    public init(
        type: TransferDataType,
        recipientData: RecipientData,
        value: BigInt,
        canChangeValue: Bool,
        ignoreValueCheck: Bool = false
    ) {
        self.type = type
        self.recipientData = recipientData
        self.value = value
        self.canChangeValue = canChangeValue
        self.ignoreValueCheck = ignoreValueCheck
    }

    public var chain: Chain {
        switch type {
        case .transfer(let asset): asset.chain
        case .transferNft(let asset):  asset.chain
        case .swap(let asset, _, _): asset.chain
        case .stake(let asset, _):  asset.chain
        case .account(let asset, _): asset.chain
        case .generic(let asset, _, _): asset.chain
        case .payment(let data): data.chain
        }
    }
}
