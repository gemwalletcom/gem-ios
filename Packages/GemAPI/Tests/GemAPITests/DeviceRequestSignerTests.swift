// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Foundation
import CryptoKit
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

    func testSignerInitFromPrivateKeyHex() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        XCTAssertEqual(signer.publicKeyHex, keyPair.publicKeyHex)
    }

    func testSignerRejectsInvalidHex() {
        XCTAssertThrowsError(try DeviceRequestSigner(privateKeyHex: "not_valid_hex"))
    }

    func testSignMessageProducesValidBase64() throws {
        let keyPair = DeviceKeyPair()
        let message = "v1.1706000000000.GET./v1/devices/abc.e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        let signature = try DeviceRequestSigner.signMessage(message, privateKeyHex: keyPair.privateKeyHex)

        let sigData = Data(base64Encoded: signature)
        XCTAssertNotNil(sigData)
        XCTAssertEqual(sigData?.count, 64)
    }

    func testSignMessageVerifiesWithPublicKey() throws {
        let keyPair = DeviceKeyPair()
        let message = "v1.1706000000000.GET./v1/devices/abc.e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        let signature = try DeviceRequestSigner.signMessage(message, privateKeyHex: keyPair.privateKeyHex)

        let pubKeyData = try dataFromHex(keyPair.publicKeyHex)
        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: pubKeyData)
        let sigData = Data(base64Encoded: signature)!

        XCTAssertTrue(publicKey.isValidSignature(sigData, for: Data(message.utf8)))
    }

    func testSignRequestSetsHeaders() throws {
        let keyPair = DeviceKeyPair()
        let signer = try DeviceRequestSigner(privateKeyHex: keyPair.privateKeyHex)
        var request = URLRequest(url: URL(string: "https://api.gem.com/v1/devices/abc")!)
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
        var request = URLRequest(url: URL(string: "https://api.gem.com/v1/devices/abc")!)
        request.httpMethod = "POST"
        request.httpBody = Data("{\"test\":true}".utf8)

        try signer.sign(request: &request)

        let bodyHash = request.value(forHTTPHeaderField: "x-device-body-hash")!
        let emptyHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        XCTAssertNotEqual(bodyHash, emptyHash)
        XCTAssertEqual(bodyHash.count, 64)
    }

    private func dataFromHex(_ hex: String) throws -> Data {
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
