// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import CryptoKit
import Primitives

public struct DeviceKeyPair: Sendable {
    public let privateKey: Data
    public let publicKey: Data

    public var privateKeyHex: String {
        privateKey.hex
    }

    public var publicKeyHex: String {
        publicKey.hex
    }

    public init() {
        let privateKey = Curve25519.Signing.PrivateKey()
        self.privateKey = privateKey.rawRepresentation
        self.publicKey = privateKey.publicKey.rawRepresentation
    }
}

public struct DeviceRequestSigner: Sendable {
    private let privateKey: Curve25519.Signing.PrivateKey

    public var publicKeyHex: String {
        privateKey.publicKey.rawRepresentation.hex
    }

    public init(privateKey: Data) throws {
        self.privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: privateKey)
    }

    public init(privateKeyHex: String) throws {
        let bytes = try Data.from(hex: privateKeyHex)
        self.privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: bytes)
    }

    public func sign(request: inout URLRequest) throws {
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path ?? "/"
        let bodyHash = SHA256.hash(data: request.httpBody ?? Data()).hex
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let message = "v1.\(timestamp).\(method).\(path).\(bodyHash)"
        let signature = try privateKey.signature(for: Data(message.utf8))

        request.setValue(signature.base64EncodedString(), forHTTPHeaderField: "x-device-signature")
        request.setValue(timestamp, forHTTPHeaderField: "x-device-timestamp")
        request.setValue(bodyHash, forHTTPHeaderField: "x-device-body-hash")
    }
}


private extension SHA256Digest {
    var hex: String {
        Data(self).hex
    }
}
