// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol TextValidator {
    func validate(_ text: String) throws
}

public struct UnknownValidationError: LocalizedError {
    public var errorDescription: String? { "error.unknown" }
}
