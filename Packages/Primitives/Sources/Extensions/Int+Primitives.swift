// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Int32 {
    public var asInt: Int {
        return Int(self)
    }
    
    public var asBigInt: BigInt {
        BigInt(self)
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
    
    public static func from(string: String) throws -> Self {
        guard let value = Self(string) else {
            throw AnyError("invalid int")
        }
        return value
    }
    
    public func isBetween(_ lowerBound: Int, and upperBound: Int) -> Bool {
        return self >= lowerBound && self <= upperBound
    }
    
    public func roundToNearest(multipleOf base: Int, mode: RoundingMode) -> Int {
        guard base > 0 else { return base }
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

extension Int32 {
    public init(string: String) throws {
        guard let value = Int32(string) else {
            throw AnyError("Invalid value: \(string)")
        }
        self = value
    }
}
extension UInt64 {
    
    public init(string: String) throws {
        guard let value = UInt64(string) else {
            throw AnyError("Invalid value: \(string)")
        }
        self = value
    }

    public var asBigInt: BigInt {
        BigInt(self)
    }
}
