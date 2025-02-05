// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import Style
import SwiftUICore

struct PriceImpactValue: Equatable {
    let type: PriceImpactType
    let value: String
}

enum PriceImpactType: Equatable {
    case low
    case medium
    case high
    case positive
}
