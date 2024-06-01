import Foundation
import BigInt

public extension BigInt {
    var zero: BigInt {
        return BigInt(0)
    }
    
    var int: Int {
        return Int(self)
    }
    
    var int64: Int64 {
        return Int64(self)
    }
    
    var UInt: UInt64 {
        return UInt64(self)
    }
    
    func increase(byPercentage percentage: Double) -> BigInt {
        let multiplier = 1 + percentage / 100.0
        let result = Double(self) * multiplier
        return BigInt(result.rounded())
    }
    
    var hexString: String {
        return String(self, radix: 16)
    }

    // little endian byte order
    func littleEndianOrder(bytes: Int) -> Data {
        // BigInt.serialize() returns a big endian array, so reverse it for little endian
        var byteArray = Array(serialize().reversed())
        // Ensure the array is bytes long, padding with 0s if necessary
        while byteArray.count < bytes {
            byteArray.append(0)
        }
        return Data(byteArray)
    }
    
    // 256 bit
    static let MAX_256 = BigInt(hex: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")!
}

// BigNumberFormatter
public extension BigInt {
    static func from(_ string: String, decimals: Int) throws -> BigInt {
        try BigNumberFormatter.standard.number(from: string, decimals: decimals)
    }
    
    static func fromHex(_ hex: String) throws -> BigInt {
        guard let value = BigInt(hex.remove0x, radix: 16) else {
            throw AnyError("invalid hex value: \(hex)")
        }
        return value
    }
    
    init?(hex: String) {
        if let value = BigInt(hex.remove0x, radix: 16) {
            self = value
        } else {
            return nil
        }
    }
}
