import XCTest
@testable import Primitives

final class AssetImageFormatterTests: XCTestCase {

    func testGetURL() {
        let formatter = AssetImageFormatter(endpoint: URL(string: "https://ping.com")!)
        
        XCTAssertEqual(
            formatter.getURL(for: AssetId(chain: .ethereum, tokenId: .none)).absoluteString,
            URL(string: "https://ping.com/blockchains/ethereum/info/logo.png")?.absoluteString
        )
        
        XCTAssertEqual(
            formatter.getURL(for: AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7")).absoluteString,
            URL(string: "https://ping.com/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png")?.absoluteString
        )
    }
}
