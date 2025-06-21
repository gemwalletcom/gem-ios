// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol TextValidator: Sendable, Identifiable {
    func validate(_ text: String) throws
}

public extension TextValidator {
    /// `validator.silent` → a silent version that always throws `SilentValidationError`
    var silent: some TextValidator { SilentTextValidator(validator: self) }

    var isSilent: Bool { self is SilentValidatable }
}

// MARK: - Silent

private struct SilentTextValidator<V: TextValidator>: TextValidator, SilentValidatable {
    let validator: V

    func validate(_ text: String) throws {
        do { try validator.validate(text) }
        catch { throw SilentValidationError() }
    }

    var id: V.ID { validator.id }
}
