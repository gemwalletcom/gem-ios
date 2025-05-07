import Foundation

public extension Data {
    
    // from https://github.com/trustwallet/wallet-core/blob/master/swift/Sources/Extensions/Data%2BHex.swift#L11
    init?(fromHex hex: String) {
        let string: String
        if hex.hasPrefix("0x") {
            string = String(hex.dropFirst(2))
        } else {
            string = hex
        }

        if string.count % 2 != 0 {
            return nil
        }
        if string.contains(where: { !$0.isHexDigit }) {
            return nil
        }

        guard let stringData = string.data(using: .ascii, allowLossyConversion: true) else {
            return nil
        }

        self.init(capacity: string.count / 2)
        let stringBytes = Array(stringData)
        for i in stride(from: 0, to: stringBytes.count, by: 2) {
            guard let high = Data.value(of: stringBytes[i]) else {
                return nil
            }
            if i < stringBytes.count - 1, let low = Data.value(of: stringBytes[i + 1]) {
                append((high << 4) | low)
            } else {
                append(high)
            }
        }
    }
    
    static func from(hex: String) throws -> Data {
        guard let data = Data(fromHex: hex) else {
            throw AnyError("invalid hex value")
        }
        return data
    }
    
    /// Converts an ASCII byte to a hex value.
    private static func value(of nibble: UInt8) -> UInt8? {
        guard let letter = String(bytes: [nibble], encoding: .ascii) else { return nil }
        return UInt8(letter, radix: 16)
    }
    
    var prettyJSON: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }
        return prettyPrintedString
    }
}
