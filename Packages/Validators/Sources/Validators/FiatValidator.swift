// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct FiatValidator: TextValidator {
    private let validators: [any ValueValidator<Double>]
    
    public init(validators: [any ValueValidator<Double>]) {
        self.validators = validators
    }
    
    public func validate(_ text: String) throws {
        guard let value = Double(text) else {
            throw AnyError("Invalid number")
        }
        
        for validator in validators {
            try validator.validate(value)
        }
    }
    
    public var id: String { "FiatValidator" }
}

public extension TextValidator where Self == FiatValidator {
    static func fiat(validators: [any ValueValidator<Double>]) -> Self {
        .init(validators: validators)
    }
}
