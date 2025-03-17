// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct ValidatedInput<T,P: ValidatorConvertible> {
    private let validator: P
    public var value: P.T?
    
    public var unwrappedValue: P.T {
        get throws {
            try validator.validate(value)
            
            guard let value else {
                throw ValidationError.invalid(description: validator.errorMessage)
            }
            
            return value
        }
    }
    
    public init(
        validator: P,
        value: P.T?
    ) {
        self.validator = validator
        self.value = value
    }
    
    public func validate() throws {
        try validator.validate(value)
    }
}
