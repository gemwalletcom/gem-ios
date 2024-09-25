import XCTest
import Primitives

final class AssetIdTests: XCTestCase {

    func testId() {
        XCTAssertNil(try? AssetId(id: ""))
        XCTAssertNil(try? AssetId(id: "random_chain"))
        XCTAssertEqual(try! AssetId(id: "bitcoin"), AssetId(chain: .bitcoin, tokenId: .none))
        XCTAssertEqual(try! AssetId(id: "ethereum_0x123"), AssetId(chain: .ethereum, tokenId: "0x123"))
        XCTAssertEqual(try! AssetId(id: "ton_EQAhRC_oZ4B9VgMltfNkENSdLktlMADPE73zIiIcL6es2o7-"), AssetId(chain: .ton, tokenId: "EQAhRC_oZ4B9VgMltfNkENSdLktlMADPE73zIiIcL6es2o7-"))
        XCTAssertEqual(try! AssetId(id: "ton_EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT"), AssetId(chain: .ton, tokenId: "EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT"))
    }
    
    func testType() {
        XCTAssertEqual(AssetId(chain: .ethereum, tokenId: .none).type, .native)
        XCTAssertEqual(AssetId(chain: .ethereum, tokenId: "0x123").type, .token)
    }
    
    func testIdentifier() {
        XCTAssertEqual(AssetId(chain: .ethereum, tokenId: .none).identifier, "ethereum")
        XCTAssertEqual(AssetId(chain: .ethereum, tokenId: "").identifier, "ethereum")
        XCTAssertEqual(AssetId(chain: .ethereum, tokenId: "0x123").identifier, "ethereum_0x123")
    }
}
