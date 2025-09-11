// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import enum Gemstone.GemAddressStatus

extension GemAddressStatus {
    public func map() -> AddressStatus {
        switch self {
        case .multiSignature: .multiSignature
        }
    }
}
