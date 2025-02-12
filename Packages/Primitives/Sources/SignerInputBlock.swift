// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SignerInputBlock: Sendable {
    public let number: Int
    public let hash: String
    public let version: Int
    public let timestamp: Int
    public let transactionTreeRoot: String
    public let parentHash: String
    public let witnessAddress: String
    
    public init(
        number: Int = 0,
        hash: String = "",
        version: Int = 0,
        timestamp: Int = 0,
        transactionTreeRoot: String = "",
        parentHash: String = "",
        widnessAddress: String = ""
    ) {
        self.number = number
        self.hash = hash
        self.version = version
        self.timestamp = timestamp
        self.transactionTreeRoot = transactionTreeRoot
        self.parentHash = parentHash
        self.witnessAddress = widnessAddress
    }
}
