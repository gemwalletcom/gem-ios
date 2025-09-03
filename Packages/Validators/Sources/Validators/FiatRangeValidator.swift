// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct FiatRangeValidator<T: Comparable & Sendable>: ValueValidator {
    public typealias Formatted = T
    
    private let range: ClosedRange<T>
    private let minimumValueText: String
    private let maximumValueText: String

    public init(
        range: ClosedRange<T>,
        minimumValueText: String,
        maximumValueText: String
    ) {
        self.range = range
        self.minimumValueText = minimumValueText
        self.maximumValueText = maximumValueText
    }

    public func validate(_ value: T) throws {
        guard value >= range.lowerBound else {
            throw AnyError(Localized.Transfer.minimumAmount(minimumValueText))
        }
        guard value <= range.upperBound else {
            throw AnyError(Localized.Transfer.maximumAmount(maximumValueText))
        }
    }

    public var id: String { "FiatRangeValidator" }
}
