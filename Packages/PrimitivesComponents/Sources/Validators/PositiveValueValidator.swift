// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct PositiveValueValidator<V>: ValueValidator where V: ValueValidatable
{
    public init() {}

    public func validate(_ value: V) throws {
        guard value > 0 else {
            throw TransferError.invalidAmount
        }
    }

    public var id: String { "PositiveValidator<\(V.self)>" }
}
