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
}
