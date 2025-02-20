// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionPreload: Sendable {
    public let blockHash: String
    public let blockNumber: Int
    public let utxos: [UTXO]
    public let sequence: Int
    public let chainId: String
    public let isDestinationAddressExist: Bool
    
    public init(
        blockHash: String = "",
        blockNumber: Int = 0,
        utxos: [UTXO] = [],
        sequence: Int = 0,
        chainId: String = "",
        isDestinationAddressExist: Bool = false
    ) {
        self.blockHash = blockHash
        self.blockNumber = blockNumber
        self.utxos = utxos
        self.sequence = sequence
        self.chainId = chainId
        self.isDestinationAddressExist = isDestinationAddressExist
    }
}

extension TransactionPreload {
    public static let none: TransactionPreload = .init()
}
