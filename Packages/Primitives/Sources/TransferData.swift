// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferData: Sendable, Hashable {
    public let type: TransferDataType
    public let recipientData: RecipientData //TODO: Unless used in a few places
    public let value: BigInt
    
    public init(
        type: TransferDataType,
        recipientData: RecipientData,
        value: BigInt
    ) {
        self.type = type
        self.recipientData = recipientData
        self.value = value
    }
    
    public var chain: Chain {
        type.chain
    }
}
