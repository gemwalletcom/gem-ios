// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionPreload: Sendable {
    public let blockhash: String
    public let utxos: [UTXO]
    public let sequence: Int
    public let chainId: String
    public let isDestinationAddressExist: Bool
    
    public init(
        blockhash: String = "",
        utxos: [UTXO] = [],
        sequence: Int = 0,
        chainId: String = "",
        isDestinationAddressExist: Bool = false
    ) {
        self.blockhash = blockhash
        self.utxos = utxos
        self.sequence = sequence
        self.chainId = chainId
        self.isDestinationAddressExist = isDestinationAddressExist
    }
}

extension TransactionPreload {
    public static let none: TransactionPreload = .init()
}
