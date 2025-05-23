// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

// TODO: - localize when implement e.g buy, sell

public struct MaximumValueValidator<Value>: ValueValidator
where Value: ValueValidatable
{
    private let maximumValue: Value
    private let maximumValueText: String

    public init(maximumValue: Value, maximumValueText: String) {
        self.maximumValue = maximumValue
        self.maximumValueText = maximumValueText
    }

    public func validate(_ value: Value) throws {
        guard value <= maximumValue else {
            throw AnyError("Maximum allowed value is \(maximumValueText)")
        }
    }

    public var id: String { "MaximumValueValidator<\(Value.self)>" }
}
