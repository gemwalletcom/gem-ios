// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.TransferDataOutputAction {
    public func map() -> Primitives.TransferDataOutputAction {
        switch self {
        case .sign: .sign
        case .send: .send
        }
    }
}

extension Primitives.TransferDataOutputAction {
    public func map() -> Gemstone.TransferDataOutputAction {
        switch self {
        case .sign: .sign
        case .send: .send
        }
    }
}
