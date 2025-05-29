// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct MinimumValueValidator<V>: ValueValidator where V: ValueValidatable
{
    private let minimumValue: V
    private let minimumValueText: String

    public init(minimumValue: V, minimumValueText: String) {
        self.minimumValue = minimumValue
        self.minimumValueText = minimumValueText
    }

    public func validate(_ value: V) throws {
        guard value >= minimumValue else {
            throw TransferError.minimumAmount(string: minimumValueText)
        }
    }

    public var id: String { "MinimumValueValidator<\(V.self)>" }
}
