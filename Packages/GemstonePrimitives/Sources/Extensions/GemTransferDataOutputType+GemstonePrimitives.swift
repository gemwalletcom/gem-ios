// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.TransferDataOutputType {
    public func map() -> TransferDataExtra.OutputType {
        switch self {
        case .encodedTransaction: .encodedTransaction
        case .signature: .signature
        }
    }
}

extension TransferDataExtra.OutputType {
    public func map() -> Gemstone.TransferDataOutputType {
        switch self {
        case .encodedTransaction: .encodedTransaction
        case .signature: .signature
        }
    }
}
