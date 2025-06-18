// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RequiredTextValidator: TextValidator {
    private let requireName: String

    public init(requireName: String) {
        self.requireName = requireName
    }

    public func validate(_ text: String) throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RequiredFieldError(field: requireName)
        }
    }

    public var id: String { requireName }
}

public extension TextValidator where Self == RequiredTextValidator {
    static func required(requireName: String) -> Self {
        .init(requireName: requireName)
    }
}
