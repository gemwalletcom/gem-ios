// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import CryptoKit
import Testing
import Primitives
@testable import GemAPI

struct DeviceRequestSignerTests {

    @Test
    func keyPairGeneratesValidHex() {
        let keyPair = DeviceKeyPair()
        #expect(keyPair.privateKeyHex.count == 64)
        #expect(keyPair.publicKeyHex.count == 64)
        #expect(keyPair.privateKeyHex != keyPair.publicKeyHex)
    }

    @Test
    func keyPairGeneratesUniqueKeys() {
        let a = DeviceKeyPair()
        let b = DeviceKeyPair()
        #expect(a.privateKeyHex != b.privateKeyHex)
        #expect(a.publicKeyHex != b.publicKeyHex)
    }

    @Test
    func keyPairGeneratesValidData() {
        let keyPair = DeviceKeyPair()
        #expect(keyPair.privateKey.count == 32)
        #expect(keyPair.publicKey.count == 32)
        #expect(keyPair.privateKey != keyPair.publicKey)
    }

    @Test
    func signerInitFromPrivateKey() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKey: keyPair.privateKey)
        #expect(signer.publicKeyHex == keyPair.publicKeyHex)
    }

    @Test
    func signerInitFromPrivateKeyHex() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        #expect(signer.publicKeyHex == keyPair.publicKeyHex)
    }

    @Test
    func signerRejectsInvalidHex() {
        do {
            _ = try DeviceRequestSigner(privateKeyHex: "not_valid_hex")
            Issue.record("Expected invalid hex to throw")
        } catch {}
    }

    @Test
    func signSetsAuthorizationHeader() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request)

        let auth = try #require(request.value(forHTTPHeaderField: "Authorization"))
        #expect(auth.hasPrefix("Gem "))
    }

    @Test
    func signatureVerifiesWithPublicKey() throws {
        let (signer, keyPair) = try makeSigner()
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request)

        let parts = try decodePayload(from: request)
        #expect(parts.count == 5)
        #expect(parts[0] == keyPair.publicKeyHex)
        #expect(parts[2] == "")

        let message = "\(parts[1]).GET./v2/devices.\(parts[2]).\(parts[3])"
        let sigData = try Data.from(hex: parts[4])
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: Data.from(hex: keyPair.publicKeyHex))

        #expect(publicKey.isValidSignature(sigData, for: Data(message.utf8)))
    }

    @Test
    func signWithWalletId() throws {
        let (signer, _) = try makeSigner()
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices/rewards")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request, walletId: "multicoin_0xabc")

        let parts = try decodePayload(from: request)
        #expect(parts[2] == "multicoin_0xabc")

        let message = "\(parts[1]).GET./v2/devices/rewards.\(parts[2]).\(parts[3])"
        let sigData = try Data.from(hex: parts[4])
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: Data.from(hex: parts[0]))

        #expect(publicKey.isValidSignature(sigData, for: Data(message.utf8)))
    }

    @Test
    func signWithBody() throws {
        let (signer, _) = try makeSigner()
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices")!)
        request.httpMethod = "POST"
        request.httpBody = Data("{\"test\":true}".utf8)

        try signer.sign(request: &request)

        let parts = try decodePayload(from: request)
        let emptyHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        #expect(parts[3] != emptyHash)
        #expect(parts[3].count == 64)
    }

    // MARK: - Helpers

    private func makeSigner() throws -> (DeviceRequestSigner, DeviceKeyPair) {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        return (signer, keyPair)
    }

    private func decodePayload(from request: URLRequest) throws -> [String] {
        let auth = try #require(request.value(forHTTPHeaderField: "Authorization"))
        let encoded = String(auth.dropFirst("Gem ".count))
        let data = try #require(Data(base64Encoded: encoded))
        let decoded = try #require(String(data: data, encoding: .utf8))
        return decoded.split(separator: ".", maxSplits: 4, omittingEmptySubsequences: false).map(String.init)
    }
}
