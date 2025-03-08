// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Keystore

public struct BlockchainAddressValidator: ValidatorConvertible {
    public typealias T = String
    
    public var errorMessage: String {
        "Address invalid"
    }
    
    private var chain: Chain?
    
    public init(chain: Chain?) {
        self.chain = chain
    }
    
    public func isValid(_ value: String) throws -> Bool {
        let result = chain?.isValidAddress(value) == true
        return try handle(result)
    }
}
