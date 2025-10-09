// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionStateRequest: Sendable {
    public let id: String
    public let senderAddress: String
    public let recipientAddress: String
    public let block: Int
    public let createdAt: Date

    public init(
        id: String,
        senderAddress: String,
        recipientAddress: String,
        block: Int,
        createdAt: Date
    ) {
        self.id = id
        self.senderAddress = senderAddress
        self.recipientAddress = recipientAddress
        self.block = block
        self.createdAt = createdAt
    }
}