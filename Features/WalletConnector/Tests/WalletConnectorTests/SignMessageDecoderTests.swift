// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemEip712Message
import struct Gemstone.GemEip712MessageDomain
import struct Gemstone.GemEip712Section
import struct Gemstone.GemEip712Value
import struct Gemstone.SignMessage
import class Gemstone.SignMessageDecoder
import enum Gemstone.MessagePreview
import Testing
import Primitives

@testable import WalletConnector

struct SignMessageDecoderTests {
    @Test
    func testBase58() throws {
        let data = "X3CUgCGzyn43DTAbUKnTMDzcGWMooJT2hPSZinjfN1QUgVNYYfeoJ5zg6i4Nd5coKGUrNpEYVoD".data(using: .utf8)!
        let message = SignMessage(chain: "solana", signType: .base58, data: data)
        let decoder = SignMessageDecoder(message: message)
        
        #expect(try decoder.hash().encodeString() == "This is an example message to be signed - 1747125759060")
        #expect(decoder.plainPreview() == "This is an example message to be signed - 1747125759060")
        #expect(try decoder.preview() == .text("This is an example message to be signed - 1747125759060"))
    }
// TODO: Enable later
//    @Test
//    func EIP712Preview() throws {
//        let string: String = try Bundle.decode(from: "eip712", withExtension: "json", in: .module)
//        let prettyString: String = try Bundle.decode(from: "eip712pretty", withExtension: "json", in: .module)
//        let data = string.data(using: .utf8)!
//        let message = SignMessage(signType: .eip712, data: data)
//        let decoder = SignMessageDecoder(message: message)
//
//        #expect(decoder.hash().map { String(format: "%02x", $0) }.joined() == "be609aee343fb3c4b28e1df9e632fca64fcfaede20f02e86244efddf30957bd2")
//        #expect(decoder.plainPreview() == prettyString)
//        #expect(try decoder.preview() == MessagePreview.eip712Mock())
//    }
}

extension MessagePreview {
    static func eip712Mock() -> MessagePreview {
        MessagePreview.eip712(
            GemEip712Message(
                domain: GemEip712MessageDomain(
                    name: "Ether Mail",
                    version: "1",
                    chainId: 1,
                    verifyingContract: "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
                    salts: nil
                ),
                message: [
                    GemEip712Section(
                        name: "Mail",
                        values: [
                            GemEip712Value(name: "from", value: "{name, wallet}"),
                            GemEip712Value(name: "to", value: "{name, wallet}"),
                            GemEip712Value(name: "contents", value: "Hello, Bob!")
                        ]
                    )
                ]
            )
        )
    }
}
