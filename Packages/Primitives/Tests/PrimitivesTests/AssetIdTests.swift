// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives

final class AssetIdTests {
    
    @Test
    func testId() throws {
        #expect((try? AssetId(id: "")) == nil)
        #expect((try? AssetId(id: "random_chain")) == nil)
        #expect((try AssetId(id: "bitcoin") == AssetId(chain: .bitcoin, tokenId: .none)))
        #expect(try AssetId(id: "ethereum_0x123") == AssetId(chain: .ethereum, tokenId: "0x123"))
        #expect((try AssetId(id: "ton_EQAhRC_oZ4B9VgMltfNkENSdLktlMADPE73zIiIcL6es2o7-") == AssetId(chain: .ton, tokenId: "EQAhRC_oZ4B9VgMltfNkENSdLktlMADPE73zIiIcL6es2o7-")))
        #expect((try AssetId(id: "ton_EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT") == AssetId(chain: .ton, tokenId: "EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT")))
    }

    @Test
    func testType() {
        #expect(AssetId(chain: .ethereum, tokenId: .none).type == .native)
        #expect(AssetId(chain: .ethereum, tokenId: "0x123").type == .token)
    }

    @Test
    func testIdentifier() {
        #expect(AssetId(chain: .ethereum, tokenId: .none).identifier == "ethereum")
        #expect(AssetId(chain: .ethereum, tokenId: "").identifier == "ethereum")
        #expect(AssetId(chain: .ethereum, tokenId: "0x123").identifier == "ethereum_0x123")
    }
    
    @Test
    func testStringDecodingWithTokenId() throws {
        let json = #""ethereum_0xabc123""#.data(using: .utf8)!
        let assetId = try JSONDecoder().decode(AssetId.self, from: json)

        #expect(AssetId(chain: .ethereum, tokenId: "0xabc123") == assetId)
    }

    @Test
    func testStringDecodingWithoutTokenId() throws {
        let json = #""solana""#.data(using: .utf8)!
        let assetId = try JSONDecoder().decode(AssetId.self, from: json)
        
        #expect(AssetId(chain: .solana, tokenId: nil) == assetId)
    }

    @Test
    func testEncodingAsString() throws {
        let asset = AssetId(chain: .ethereum, tokenId: "0xabc123")
        let data = try JSONEncoder().encode(asset)
        
        #expect(String(data: data, encoding: .utf8) == #""ethereum_0xabc123""#)
    }

    @Test
    func testEncodingAsStringWithoutTokenId() throws {
        let asset = AssetId(chain: .solana, tokenId: nil)
        let data = try JSONEncoder().encode(asset)

        #expect(String(data: data, encoding: .utf8) == #""solana""#)
    }
    
    @Test
    func testObjectDecoding() throws {
        let asset = AssetId(chain: .ethereum, tokenId: "0xabc123")
        let json = #"{"chain":"ethereum","tokenId":"0xabc123"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AssetId.self, from: json)
        
        #expect(asset == decoded)
    }
}
