// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct MinimumValueValidator<Value>: ValueValidator
where Value: ValueValidatable
{
    private let minimumValue: Value
    private let minimumValueText: String

    public init(minimumValue: Value, minimumValueText: String) {
        self.minimumValue = minimumValue
        self.minimumValueText = minimumValueText
    }

    public func validate(_ value: Value) throws {
        guard value >= minimumValue else {
            throw TransferError.minimumAmount(string: minimumValueText)
        }
    }

    public var id: String { "MinimumValueValidator<\(Value.self)>" }
}
