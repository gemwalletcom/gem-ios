// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionPreloadInput: Sendable {
    public let asset: Asset
    public let senderAddress: String
    public let destinationAddress: String
    
    public init(
        asset: Asset,
        senderAddress: String,
        destinationAddress: String
    ) {
        self.asset = asset
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
    }
}
