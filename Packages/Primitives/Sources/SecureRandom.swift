import Foundation
import Security

public struct SecureRandom {
    
    public static func generateKey(length: Int = 32) throws -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)
        
        guard status == errSecSuccess else {
            throw AnyError("generateKey failed: \(status)")
        }
        
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}
