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

    func testSignatureIsValidBase64With64Bytes() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v1/devices/abc")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request)

        let signature = request.value(forHTTPHeaderField: "x-device-signature")!
        let sigData = Data(base64Encoded: signature)
        XCTAssertNotNil(sigData)
        XCTAssertEqual(sigData?.count, 64)
    }

    func testSignatureVerifiesWithPublicKey() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v1/devices/abc")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request)

        let signature = request.value(forHTTPHeaderField: "x-device-signature")!
        let timestamp = request.value(forHTTPHeaderField: "x-device-timestamp")!
        let bodyHash = request.value(forHTTPHeaderField: "x-device-body-hash")!
        let message = "v1.\(timestamp).GET./v1/devices/abc.\(bodyHash)"

        let pubKeyData = try Data.from(hex: keyPair.publicKeyHex)
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: pubKeyData)
        let sigData = Data(base64Encoded: signature)!

        XCTAssertTrue(publicKey.isValidSignature(sigData, for: Data(message.utf8)))
    }

    func testSignRequestSetsHeaders() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v1/devices/abc")!)
        request.httpMethod = "GET"

        try signer.sign(request: &request)

        XCTAssertNotNil(request.value(forHTTPHeaderField: "x-device-signature"))
        XCTAssertNotNil(request.value(forHTTPHeaderField: "x-device-timestamp"))
        XCTAssertNotNil(request.value(forHTTPHeaderField: "x-device-body-hash"))

        let timestamp = request.value(forHTTPHeaderField: "x-device-timestamp")!
        XCTAssertNotNil(Int(timestamp))
        XCTAssertGreaterThan(Int(timestamp)!, 1_000_000_000_000)

        let emptyHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        XCTAssertEqual(request.value(forHTTPHeaderField: "x-device-body-hash"), emptyHash)
    }

    func testSignRequestWithBody() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        var request = URLRequest(url: URL(string: "https://api.gemwallet.com/v1/devices/abc")!)
        request.httpMethod = "POST"
        request.httpBody = Data("{\"test\":true}".utf8)

        try signer.sign(request: &request)

        let bodyHash = request.value(forHTTPHeaderField: "x-device-body-hash")!
        let emptyHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        XCTAssertNotEqual(bodyHash, emptyHash)
        XCTAssertEqual(bodyHash.count, 64)
    }

}
