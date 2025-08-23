// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct SignerInput {
    public let type: TransferDataType
    public let asset: Asset
    public let value: BigInt
    public let fee: Fee
    public let useMaxAmount: Bool
    public let memo: String?
    public let senderAddress: String
    public let destinationAddress: String

    public let metadata: TransactionLoadMetadata

    public init(
        type: TransferDataType,
        asset: Asset,
        value: BigInt,
        fee: Fee,
        isMaxAmount: Bool,
        memo: String?,
        senderAddress: String,
        destinationAddress: String,
        metadata: TransactionLoadMetadata = .none
    ) {
        self.type = type
        self.asset = asset
        self.value = value
        self.fee = fee
        self.useMaxAmount = isMaxAmount
        self.memo = memo
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
        self.metadata = metadata
    }
}
