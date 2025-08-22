// Copyright (c). Gem Wallet. All rights reserved.

import Foundation


public struct TransactionData: Sendable {
    public let data: SigningData
    public var fee: Fee
    public let messageBytes: String
    public let metadata: TransactionLoadMetadata

    public init(
        data: SigningData = .none,
        fee: Fee,
        messageBytes: String = "",
        metadata: TransactionLoadMetadata = .none
    ) {
        self.data = data
        self.fee = fee
        self.messageBytes = messageBytes
        self.metadata = metadata
    }
}

