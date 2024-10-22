// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Primitives

public struct FeeUnit {
    public let type: FeeUnitType
    public let value: BigInt
    
    public init(type: FeeUnitType, value: BigInt) {
        self.type = type
        self.value = value
    }
}
