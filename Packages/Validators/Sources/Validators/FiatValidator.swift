// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct FiatValidator: TextValidator {
    private let validators: [any ValueValidator<Int>]
    
    public init(validators: [any ValueValidator<Int>]) {
        self.validators = validators
    }
    
    public func validate(_ text: String) throws {
        guard let value = Int(text) else {
            throw AnyError("Invalid number")
        }
        
        for validator in validators {
            try validator.validate(value)
        }
    }
    
    public var id: String { "FiatValidator" }
}

public extension TextValidator where Self == FiatValidator {
    static func fiat(validators: [any ValueValidator<Int>]) -> Self {
        .init(validators: validators)
    }
}
