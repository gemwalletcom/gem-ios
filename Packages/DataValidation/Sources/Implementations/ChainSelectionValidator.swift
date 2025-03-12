// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct ChainSelectionValidator: ValidatorConvertible {
    public typealias T = Chain?
    
    public let errorMessage: String
    
    public init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    public func validate(_ value: Chain?) throws {
        let isValid = value != nil
        if !isValid {
            throw ValidationError.invalid(description: errorMessage)
        }
    }
}
