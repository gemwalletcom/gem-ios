// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public struct TransferAmount: Equatable, Sendable {
    public let value: BigInt

    // freezeValue: ONLY TRON staking v2 related
    public let freezeValue: BigInt
    public let networkFee: BigInt
    public let useMaxAmount: Bool
    
    public init(
        value: BigInt,
        networkFee: BigInt,
        freezeValue: BigInt,
        useMaxAmount: Bool
    ) {
        self.value = value
        self.networkFee = networkFee
        self.freezeValue = freezeValue
        self.useMaxAmount = useMaxAmount
    }
}
