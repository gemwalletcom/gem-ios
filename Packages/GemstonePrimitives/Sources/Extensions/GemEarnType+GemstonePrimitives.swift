// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension Gemstone.EarnType {
    public func map() throws -> Primitives.EarnType {
        switch self {
        case .deposit(let validator): .deposit(try validator.map())
        case .withdraw(let delegation): .withdraw(try delegation.map())
        }
    }
}

extension Primitives.EarnType {
    public func map() -> Gemstone.EarnType {
        switch self {
        case .deposit(let validator): .deposit(validator.map())
        case .withdraw(let delegation): .withdraw(delegation.map())
        }
    }
}
