// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public typealias ValueValidatable = Comparable & Sendable & ExpressibleByIntegerLiteral

public protocol ValueValidator<Formatted>: Identifiable, Sendable {
    associatedtype Formatted
    func validate(_ value: Formatted) throws
}

public extension ValueValidator {
    /// `validator.silent` → a silent version that always throws `SilentValidationError`
    var silent: some ValueValidator<Formatted> { SilentValueValidator(validator: self) }
    var isSilent: Bool { self is SilentValidatable }
}

// MARK: - Silent

private struct SilentValueValidator<V: ValueValidator>: ValueValidator, SilentValidatable {
    typealias Formatted = V.Formatted

    let validator: V

    func validate(_ value: Formatted) throws {
        do { try validator.validate(value) }
        catch { throw SilentValidationError() }
    }

    var id: V.ID { validator.id }
}

extension Comparable where Self: SignedNumeric {
    func isBetween(_ a: Self, and b: Self) -> Bool {
        self >= a && self <= b
    }
}
