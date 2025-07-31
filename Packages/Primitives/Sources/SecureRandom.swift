import Foundation
import Security

public enum SecureRandom {
    public static func generateKey(length: Int = 32) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, length, &bytes)

        guard status == errSecSuccess else {
            throw AnyError("generateKey failed: \(status)")
        }

        return Data(bytes)
    }
}
