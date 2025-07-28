import Foundation

public struct SignatureParser {
    
    public enum ParseError: Error {
        case invalidLength
        case invalidHexFormat
    }
    
    public static func parseSignature(_ hexSignature: String) throws -> (r: String, s: String, v: Int) {
        let signature = hexSignature.replacingOccurrences(of: "0x", with: "")
        
        guard signature.count == 130 else {
            throw ParseError.invalidLength
        }
        
        guard signature.allSatisfy({ $0.isHexDigit }) else {
            throw ParseError.invalidHexFormat
        }
        
        let rHex = String(signature.prefix(64))
        let sHex = String(signature.dropFirst(64).prefix(64))
        let vHex = String(signature.suffix(2))
        
        guard let vByte = UInt8(vHex, radix: 16) else {
            throw ParseError.invalidHexFormat
        }
        
        return (
            r: "0x" + rHex,
            s: "0x" + sHex,
            v: Int(vByte)
        )
    }
}