// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualType {
    public func map() throws -> Primitives.PerpetualType {
        switch self {
        case .open(let confirmData): .open(try confirmData.map())
        case .close(let confirmData): .close(try confirmData.map())
        case .modify(let data): .modify(try data.map())
        }
    }
}

extension Primitives.PerpetualType {
    public func map() -> Gemstone.PerpetualType {
        switch self {
        case .open(let confirmData): .open(confirmData.map())
        case .close(let confirmData): .close(confirmData.map())
        case .modify(let data): .modify(data.map())
        }
    }
}
