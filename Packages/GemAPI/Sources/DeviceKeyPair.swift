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
