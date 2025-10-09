// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct TransactionData: Sendable {
    public var fee: Fee
    public let metadata: TransactionLoadMetadata

    public init(
        fee: Fee,
        metadata: TransactionLoadMetadata = .none
    ) {
        self.fee = fee
        self.metadata = metadata
    }
}

