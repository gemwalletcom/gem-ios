// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import enum Gemstone.AddressStatus

extension Gemstone.AddressStatus {
    public func map() -> Primitives.AddressStatus {
        switch self {
        case .multiSignature: .multiSignature
        }
    }
}
