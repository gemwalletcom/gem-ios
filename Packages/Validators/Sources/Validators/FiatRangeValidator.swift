// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct FiatRangeValidator: ValueValidator {
    private let range: ClosedRange<Int>
    private let minimumValueText: String
    private let maximumValueText: String

    public init(
        range: ClosedRange<Int>,
        minimumValueText: String,
        maximumValueText: String
    ) {
        self.range = range
        self.minimumValueText = minimumValueText
        self.maximumValueText = maximumValueText
    }

    public func validate(_ value: Int) throws {
        guard value >= range.lowerBound else {
            throw AnyError(Localized.Transfer.minimumAmount(minimumValueText))
        }
        guard value <= range.upperBound else {
            throw AnyError(Localized.Transfer.maximumAmount(maximumValueText))
        }
    }

    public var id: String { "FiatRangeValidator" }
}
