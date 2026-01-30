// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import CryptoKit

public struct DeviceKeyPair: Sendable {
    public let privateKeyHex: String
    public let publicKeyHex: String

    public init() {
        let privateKey = Curve25519.Signing.PrivateKey()
        self.privateKeyHex = privateKey.rawRepresentation.map { String(format: "%02x", $0) }.joined()
        self.publicKeyHex = privateKey.publicKey.rawRepresentation.map { String(format: "%02x", $0) }.joined()
    }
}

public struct DeviceRequestSigner: Sendable {
    private let privateKey: Curve25519.Signing.PrivateKey

    public var publicKeyHex: String {
        privateKey.publicKey.rawRepresentation.map { String(format: "%02x", $0) }.joined()
    }

    public init(privateKeyHex: String) throws {
        let bytes = try Self.dataFromHex(privateKeyHex)
        self.privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: bytes)
    }

    public func sign(request: inout URLRequest) throws {
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path ?? "/"
        let bodyHash = SHA256.hash(data: request.httpBody ?? Data()).hexString
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let message = "v1.\(timestamp).\(method).\(path).\(bodyHash)"
        let signature = try privateKey.signature(for: Data(message.utf8))

        request.setValue(signature.base64EncodedString(), forHTTPHeaderField: "x-device-signature")
        request.setValue(timestamp, forHTTPHeaderField: "x-device-timestamp")
        request.setValue(bodyHash, forHTTPHeaderField: "x-device-body-hash")
    }

    public static func signMessage(_ message: String, privateKeyHex: String) throws -> String {
        let bytes = try dataFromHex(privateKeyHex)
        let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: bytes)
        let signature = try privateKey.signature(for: Data(message.utf8))
        return signature.base64EncodedString()
    }
}

private extension DeviceRequestSigner {
    static func dataFromHex(_ hex: String) throws -> Data {
        let len = hex.count / 2
        var data = Data(capacity: len)
        var index = hex.startIndex
        for _ in 0..<len {
            let nextIndex = hex.index(index, offsetBy: 2)
            guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else {
                throw CryptoKitError.incorrectParameterSize
            }
            data.append(byte)
            index = nextIndex
        }
        return data
    }
}

private extension SHA256Digest {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
