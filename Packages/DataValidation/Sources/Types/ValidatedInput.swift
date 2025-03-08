// Copyright (c). Gem Wallet. All rights reserved.

public struct ValidatedInput<T,P: ValidatorConvertible> {
    private let validator: P
    public var value: P.T
    
    public init(
        validator: P,
        value: P.T
    ) {
        self.validator = validator
        self.value = value
    }
    
    public func validate() throws -> Bool {
        return try validator.isValid(value)
    }
}
