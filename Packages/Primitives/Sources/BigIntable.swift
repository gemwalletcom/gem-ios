import Foundation
import BigInt

public struct BigIntable: Equatable {
    public let value: BigInt

    public init(_ value: BigInt) {
        self.value = value
    }
}

extension BigIntable: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            self = .init(BigInt(intValue))
            return
        }

        let decoded = try container.decode(String.self)
        guard
            let value = BigInt(decoded.remove0x, radix: decoded.hasPrefix("0x") ? 16 : 10)
        else {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Can't decode value to BigInt, not valid integer or string"
            )
            throw DecodingError.dataCorrupted(context)
        }
        self = .init(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}

public extension BigInt {
    var codable: BigIntable {
        return BigIntable(self)
    }
}
