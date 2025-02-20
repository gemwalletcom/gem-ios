// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct PriceImpactValue: Equatable {
    let type: PriceImpactType
    let value: String
}

public enum PriceImpactType: Equatable {
    case low
    case medium
    case high
    case positive
}
