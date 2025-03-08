// Copyright (c). Gem Wallet. All rights reserved.

public struct ContactDescriptionValidator: ValidatorConvertible {
    public typealias T = String
    
    public var errorMessage: String {
        "Please enter a valid description (less than 50 characters)"
    }
    
    public init() { }
    
    public func isValid(_ value: String) throws -> Bool {
        let result = value.range(of: "^.{0,50}$", options: .regularExpression) != nil
        return try handle(result)
    }
}
