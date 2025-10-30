// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.GemPerpetualType {
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
    public func map() -> Gemstone.GemPerpetualType {
        switch self {
        case .open, .increase: .open(data.map())
        case .reduce(let reduceData): .open(reduceData.data.map())
        case .close: .close(data.map())
        }
    }
}
