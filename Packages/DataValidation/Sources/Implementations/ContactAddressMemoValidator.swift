// Copyright (c). Gem Wallet. All rights reserved.

public struct ContactAddressMemoValidator: ValidatorConvertible {
    public typealias T = String
    
    public var errorMessage: String {
        "Please enter a valid description (less than 150 characters)"
    }
    
    public init() { }
    
    public func isValid(_ value: String) throws -> Bool {
        let result = value.range(of: "^.{0,150}$", options: .regularExpression) != nil
        return try handle(result)
    }
}
