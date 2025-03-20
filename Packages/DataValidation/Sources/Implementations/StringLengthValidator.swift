// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct StringLengthValidator: ValidatorConvertible {
    public typealias T = String
    
    private let min: Int
    private let max: Int
    public let errorMessage: String
    
    public init(min: Int = 0, max: Int, errorMessage: String) {
        self.min = min
        self.max = max
        self.errorMessage = errorMessage
    }
    
    public func validate(_ value: String?) throws {
        let length = (value?.count).or(0)
        let isValid = length >= min && length <= max
        if !isValid {
            throw ValidationError.invalid(description: errorMessage)
        }
    }
}
