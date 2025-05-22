// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct PositiveValueValidator<Value>: ValueValidator
where Value: ValueValidatable
{
    public init() {}

    public func validate(_ value: Value) throws {
        guard value > 0 else {
            throw TransferError.invalidAmount
        }
    }

    public var id: String { "PositiveValidator<\(Value.self)>" }
}
