// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol FormattedValidator: TextValidator {
    associatedtype Formatted
    var validators: [any ValueValidator<Formatted>] { get }

    func format(_ text: String) throws -> Formatted
}

public extension FormattedValidator {
    func validate(_ text: String) throws {
        let value = try format(text)
        try validators.forEach { try $0.validate(value) }
    }
}
