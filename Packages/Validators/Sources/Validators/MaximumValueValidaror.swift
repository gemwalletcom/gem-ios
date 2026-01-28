// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

// TODO: - localize when implement e.g buy, sell

struct MaximumValueValidator<V>: ValueValidator where V: ValueValidatable
{
    private let maximumValue: V
    private let maximumValueText: String

    init(maximumValue: V, maximumValueText: String) {
        self.maximumValue = maximumValue
        self.maximumValueText = maximumValueText
    }

    func validate(_ value: V) throws {
        guard value <= maximumValue else {
            throw AnyError("Maximum allowed value is \(maximumValueText)")
        }
    }

    var id: String { "MaximumValueValidator<\(V.self)>" }
}
