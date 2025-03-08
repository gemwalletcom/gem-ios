// Copyright (c). Gem Wallet. All rights reserved.

public struct ContactNameValidator: ValidatorConvertible {
    public typealias T = String
    
    public var errorMessage: String {
        "Please enter a valid description (less than 25 characters)"
    }
    
    public init() { }
    
    public func isValid(_ value: String) throws -> Bool {
        let result = value.range(of: "^.{1,25}$", options: .regularExpression) != nil
        return try handle(result)
    }
}
