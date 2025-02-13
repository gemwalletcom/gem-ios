// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionPreloadInput: Sendable {
    public let senderAddress: String
    public let destinationAddress: String
    
    public init(
        senderAddress: String,
        destinationAddress: String
    ) {
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
    }
}
