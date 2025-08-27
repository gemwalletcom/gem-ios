// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemTransferDataOutputType {
    public func map() -> TransferDataExtra.OutputType {
        switch self {
        case .encodedTransaction: .encodedTransaction
        case .signature: .signature
        }
    }
}

extension TransferDataExtra.OutputType {
    public func map() -> GemTransferDataOutputType {
        switch self {
        case .encodedTransaction: .encodedTransaction
        case .signature: .signature
        }
    }
}
