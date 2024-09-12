import XCTest
import Primitives
@testable import Gem

final class WalletSupportedChainsTests: XCTestCase {
    func testChainsAll() {
        let wallet = Wallet.mock(accounts: [
            .mock(chain: .bitcoin),
            .mock(chain: .doge),
            .mock(chain: .ethereum)
        ])

        let result = wallet.chains(type: .all)
        let expectedChains: [Chain] = [.bitcoin, .ethereum, .doge]
        XCTAssertEqual(result, expectedChains)
    }

    func testChainsWithTokens() {
        let wallet = Wallet.mock(accounts: [
            .mock(chain: .bitcoin),
            .mock(chain: .doge),
            .mock(chain: .ethereum)
        ])

        let result = wallet.chains(type: .withTokens)
        let expectedChains: [Chain] = [.ethereum]
        XCTAssertEqual(result, expectedChains)
    }

    func testChainSorting() {
        let wallet = Wallet.mock(accounts: [
            .mock(chain: .doge),
            .mock(chain: .ethereum),
            .mock(chain: .bitcoin)
        ])

        let result = wallet.chains(type: .all)
        let expectedChains: [Chain] = [.bitcoin, .ethereum, .doge]
        XCTAssertEqual(result, expectedChains)
    }
}
