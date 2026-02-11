// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import CryptoKit
import Primitives

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

    public func sign(request: inout URLRequest, walletId: String = "") throws {
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path ?? "/"
        let bodyHash = Data(SHA256.hash(data: request.httpBody ?? Data())).hex
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))

        let message = "\(timestamp).\(method).\(path).\(walletId).\(bodyHash)"
        let signature = try privateKey.signature(for: Data(message.utf8))

        let payload = "\(publicKeyHex).\(timestamp).\(walletId).\(bodyHash).\(signature.rawRepresentation.hex)"
        let encoded = Data(payload.utf8).base64EncodedString()
        request.setValue("Gem \(encoded)", forHTTPHeaderField: "Authorization")
    }
}
