// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Keystore

public struct BlockchainAddressValidator: ValidatorConvertible {
    public typealias T = String
    
    public let errorMessage: String
    private let chain: Chain
    
    public init(chain: Chain, errorMessage: String) {
        self.chain = chain
        self.errorMessage = errorMessage
    }
    
    public func validate(_ value: String?) throws {
        guard let value else {
            throw ValidationError.invalid(description: errorMessage)
        }
        
        let isValid = chain.isValidAddress(value)
        if !isValid {
            throw ValidationError.invalid(description: errorMessage)
        }
    }
}
