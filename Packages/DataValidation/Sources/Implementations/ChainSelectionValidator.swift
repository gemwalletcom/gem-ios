// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct ChainSelectionValidator: ValidatorConvertible {
    public typealias T = Chain?
    
    public var errorMessage: String {
        "Please select a chain"
    }
    
    public init() { }
    
    public func isValid(_ value: Chain?) throws -> Bool {
        let result = value != nil
        return try handle(result)
    }
}
