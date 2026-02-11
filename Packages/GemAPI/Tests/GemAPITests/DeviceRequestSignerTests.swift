// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Foundation
import CryptoKit
import Primitives
@testable import GemAPI

final class DeviceRequestSignerTests: XCTestCase {

    func testKeyPairGeneratesValidHex() {
        let keyPair = DeviceKeyPair()
        XCTAssertEqual(keyPair.privateKeyHex.count, 64)
        XCTAssertEqual(keyPair.publicKeyHex.count, 64)
        XCTAssertNotEqual(keyPair.privateKeyHex, keyPair.publicKeyHex)
    }

    func testKeyPairGeneratesUniqueKeys() {
        let a = DeviceKeyPair()
        let b = DeviceKeyPair()
        XCTAssertNotEqual(a.privateKeyHex, b.privateKeyHex)
        XCTAssertNotEqual(a.publicKeyHex, b.publicKeyHex)
    }

    func testKeyPairGeneratesValidData() {
        let keyPair = DeviceKeyPair()
        XCTAssertEqual(keyPair.privateKey.count, 32)
        XCTAssertEqual(keyPair.publicKey.count, 32)
        XCTAssertNotEqual(keyPair.privateKey, keyPair.publicKey)
    }

    func testSignerInitFromPrivateKey() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKey: keyPair.privateKey)
        XCTAssertEqual(signer.publicKeyHex, keyPair.publicKeyHex)
    }

    func testSignerInitFromPrivateKeyHex() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        XCTAssertEqual(signer.publicKeyHex, keyPair.publicKeyHex)
    }

    func testSignerRejectsInvalidHex() {
        XCTAssertThrowsError(try DeviceRequestSigner(privateKeyHex: "not_valid_hex"))
    }

    func testSignSetsAuthorizationHeader() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request)

        let auth = request.value(forHTTPHeaderField: "Authorization")!
        XCTAssertTrue(auth.hasPrefix("Gem "))
    }

    func testSignatureVerifiesWithPublicKey() throws {
        let (signer, keyPair) = try makeSigner()
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request)

        let parts = try decodePayload(from: request)
        XCTAssertEqual(parts.count, 5)
        XCTAssertEqual(parts[0], keyPair.publicKeyHex)
        XCTAssertEqual(parts[2], "")

        let message = "\(parts[1]).GET./v2/devices.\(parts[2]).\(parts[3])"
        let sigData = try Data.from(hex: parts[4])
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: Data.from(hex: keyPair.publicKeyHex))

        XCTAssertTrue(publicKey.isValidSignature(sigData, for: Data(message.utf8)))
    }

    func testSignWithWalletId() throws {
        let (signer, _) = try makeSigner()
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices/rewards")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request, walletId: "multicoin_0xabc")

        let parts = try decodePayload(from: request)
        XCTAssertEqual(parts[2], "multicoin_0xabc")

        let message = "\(parts[1]).GET./v2/devices/rewards.\(parts[2]).\(parts[3])"
        let sigData = try Data.from(hex: parts[4])
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: Data.from(hex: parts[0]))

        XCTAssertTrue(publicKey.isValidSignature(sigData, for: Data(message.utf8)))
    }

    func testSignWithBody() throws {
        let (signer, _) = try makeSigner()
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v2/devices")!)
        request.httpMethod = "POST"
        request.httpBody = Data("{\"test\":true}".utf8)

        try signer.sign(request: &request)

        let parts = try decodePayload(from: request)
        let emptyHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        XCTAssertNotEqual(parts[3], emptyHash)
        XCTAssertEqual(parts[3].count, 64)
    }

    // MARK: - Helpers

    private func makeSigner() throws -> (DeviceRequestSigner, DeviceKeyPair) {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        return (signer, keyPair)
    }

    private func decodePayload(from request: URLRequest) throws -> [String] {
        let auth = try XCTUnwrap(request.value(forHTTPHeaderField: "Authorization"))
        let encoded = String(auth.dropFirst("Gem ".count))
        let decoded = String(data: try XCTUnwrap(Data(base64Encoded: encoded)), encoding: .utf8)!
        return decoded.split(separator: ".", maxSplits: 4, omittingEmptySubsequences: false).map(String.init)
    }
}
