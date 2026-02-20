// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import CryptoKit
@testable import CloudStore

struct EncryptedTransformerTests {

    @Test
    func encryptDecrypt() throws {
        let transformer = EncryptedTransformer(key: SymmetricKey(size: .bits256))
        let original = Data("secret data".utf8)

        let encrypted = try transformer.transform(original)
        let decrypted = try transformer.restore(encrypted)

        #expect(decrypted == original)
        #expect(encrypted != original)
    }

    @Test
    func wrongKeyFails() throws {
        let encrypted = try EncryptedTransformer(key: SymmetricKey(size: .bits256)).transform(Data("secret".utf8))

        #expect(throws: CryptoKitError.self) {
            try EncryptedTransformer(key: SymmetricKey(size: .bits256)).restore(encrypted)
        }
    }
}
