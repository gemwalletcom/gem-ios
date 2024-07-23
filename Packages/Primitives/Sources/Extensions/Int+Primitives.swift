// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Int32 {
    public var asInt: Int {
        return Int(self)
    }
    
    public var asString: String {
        String(self)
    }
}

extension Int {
    
    public func isBetween(_ lowerBound: Int, and upperBound: Int) -> Bool {
        return self >= lowerBound && self <= upperBound
    }
    
    public var asInt32: Int32 {
        Int32(self)
    }
    
    public var asUInt32: UInt32 {
        UInt32(self)
    }
    
    public var asUInt64: UInt64 {
        UInt64(self)
    }
    
    public var asString: String {
        String(self)
    }
    
    public var asBigInt: BigInt {
        BigInt(self)
    }
}

extension UInt64 {
    public var asBigInt: BigInt {
        BigInt(self)
    }
}
