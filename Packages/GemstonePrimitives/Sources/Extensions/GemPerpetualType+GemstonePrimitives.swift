// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.PerpetualType {
    public func map() throws -> Primitives.PerpetualType {
        switch self {
        case .open(let confirmData): .open(try confirmData.map())
        case .close(let confirmData): .close(try confirmData.map())
        case .increase(let confirmData): .increase(try confirmData.map())
        case .reduce(let reduceData): .reduce(try reduceData.map())
        }
    }
}

extension Primitives.PerpetualType {
    public func map() -> Gemstone.PerpetualType {
        switch self {
        case .open(let data), .increase(let data): .open(data.map())
        case .reduce(let data): .open(data.data.map())
        case .close(let data): .close(data.map())
        }
    }
}
