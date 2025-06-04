// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct NonPositiveSilentError: LocalizedError, SilentValidationError {
    public var errorDescription: String? { nil }
}

public struct PositiveValueValidator<V>: ValueValidator where V: ValueValidatable {
    private let isSilent: Bool

    public init(isSilent: Bool = false) {
        self.isSilent = isSilent
    }

    public func validate(_ value: V) throws {
        guard value > 0 else {
            if isSilent {
                throw NonPositiveSilentError()
            } else {
                throw TransferError.invalidAmount
            }
        }
    }

    public var id: String { "PositiveValidator<\(V.self)>" }
}
