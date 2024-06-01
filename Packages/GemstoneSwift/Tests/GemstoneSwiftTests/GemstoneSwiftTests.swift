import Gemstone
@testable import GemstoneSwift
import XCTest

final class GemstoneSwiftTests: XCTestCase {
    func testExplorerService() throws {
        XCTAssertNotNil(Gemstone.libVersion())
        XCTAssertEqual(ExplorerService.hostName(url: URL(string: "https://www.mintscan.io/")!), "MintScan")

        let hash = "f9c7f0f5d34ad038cdb097902ea66a53f53bd34709569fd9a02b761288470ee2"
        XCTAssertEqual(ExplorerService.transactionUrl(chain: .bitcoin, hash: hash).absoluteString, "https://blockchair.com/bitcoin/transaction/\(hash)?from=gemwallet")
    }
}
