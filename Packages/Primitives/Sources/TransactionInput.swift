// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransactionInput: Sendable {
    public let type: TransferDataType
    public let asset: Asset
    public let senderAddress: String
    public let destinationAddress: String
    public let value: BigInt
    public let balance: BigInt
    public let gasPrice: GasPriceType
    public let memo: String?
    public let metadata: TransactionLoadMetadata

    public init(
        type: TransferDataType,
        asset: Asset,
        senderAddress: String,
        destinationAddress: String,
        value: BigInt,
        balance: BigInt,
        gasPrice: GasPriceType,
        memo: String?,
        metadata: TransactionLoadMetadata
    ) {
        self.type = type
        self.asset = asset
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
        self.value = value
        self.balance = balance
        self.gasPrice = gasPrice
        self.memo = memo
        self.metadata = metadata
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
            gasPrice: gasPrice,
            memo: memo
        )
    }
    
    public var defaultFee: Fee {
        Fee(
            fee: gasPrice.totalFee,
            gasPriceType: gasPrice,
            gasLimit: 1
        )
    }
    
    public func defaultFee(gasLimit: BigInt) -> Fee {
        Fee(
            fee: gasPrice.totalFee,
            gasPriceType: gasPrice,
            gasLimit: gasLimit
        )
    }
    
}

