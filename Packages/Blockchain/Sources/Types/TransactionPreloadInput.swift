// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct TransactionInput: Sendable {
    public let type: TransferDataType
    public let asset: Asset
    public let senderAddress: String
    public let destinationAddress: String
    public let value: BigInt
    public let balance: BigInt
    public let memo: String?

    public init(
        type: TransferDataType,
        asset: Asset,
        senderAddress: String,
        destinationAddress: String,
        value: BigInt,
        balance: BigInt,
        feePriority: FeePriority,
        memo: String?
    ) {
        self.type = type
        self.asset = asset
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
        self.value = value
        self.balance = balance
        self.memo = memo
    }
}

extension TransactionInput {
    public var feeInput: FeeInput {
        return FeeInput(
            type: type,
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: value,
            balance: balance,
            memo: memo
        )
    }
}
