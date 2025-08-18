// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum TransactionInputType: Sendable {
    case transfer(Asset)
}

public struct GasPrice: Sendable {
    public let gasPrice: BigInt
    
    public init(gasPrice: BigInt) {
        self.gasPrice = gasPrice
    }
}

public struct TransactionLoadInput: Sendable {
    public let inputType: TransactionInputType
    public let senderAddress: String
    public let destinationAddress: String
    public let value: String
    public let gasPrice: GasPrice
    public let sequence: UInt64
    public let blockHash: String
    public let blockNumber: Int64
    public let chainId: String
    public let utxos: [UTXO]
    
    public init(
        inputType: TransactionInputType,
        senderAddress: String,
        destinationAddress: String,
        value: String,
        gasPrice: GasPrice,
        sequence: UInt64,
        blockHash: String,
        blockNumber: Int64,
        chainId: String,
        utxos: [UTXO] = []
    ) {
        self.inputType = inputType
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
        self.value = value
        self.gasPrice = gasPrice
        self.sequence = sequence
        self.blockHash = blockHash
        self.blockNumber = blockNumber
        self.chainId = chainId
        self.utxos = utxos
    }
}