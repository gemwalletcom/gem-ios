// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.TransferDataOutputType {
    public func map() -> Primitives.TransferDataOutputType {
        switch self {
        case .encodedTransaction: .encodedTransaction
        case .signature: .signature
        }
    }
}

extension Primitives.TransferDataOutputType {
    public func map() -> Gemstone.TransferDataOutputType {
        switch self {
        case .encodedTransaction: .encodedTransaction
        case .signature: .signature
        }
    }
}
