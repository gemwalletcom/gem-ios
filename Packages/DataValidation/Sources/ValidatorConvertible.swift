// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public protocol ValidatorConvertible {
    associatedtype T
    
    var errorMessage: String { get }
    
    func isValid(_ value: T) throws -> Bool
}

extension ValidatorConvertible {
    func handle(_ result: Bool) throws -> Bool {
        if result == false {
            throw ValidationError.dataNotValid(description: errorMessage)
        }
        
        return result
    }
}
