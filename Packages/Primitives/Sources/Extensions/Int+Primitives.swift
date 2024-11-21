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

public enum RoundingMode {
    case up
    case down
    case nearest
}

extension Int {
    
    public func isBetween(_ lowerBound: Int, and upperBound: Int) -> Bool {
        return self >= lowerBound && self <= upperBound
    }
    
    public func roundToNearest(multipleOf base: Int, mode: RoundingMode) -> Int {
        guard base > 0 else { return self }
        switch mode {
        case .up:
            return ((self + base - 1) / base) * base
        case .down:
            return (self / base) * base
        case .nearest:
            return ((self + base / 2) / base) * base
        }
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
