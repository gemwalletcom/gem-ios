// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

protocol FormattedValidator: TextValidator {
    associatedtype Formatted
    var validators: [any ValueValidator<Formatted>] { get }

    func format(_ text: String) throws -> Formatted
}

extension FormattedValidator {
    public func validate(_ text: String) throws {
        let value = try format(text)
        try validators.forEach { try $0.validate(value) }
    }
}
