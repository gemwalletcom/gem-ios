// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit
import Primitives

final class WalletChainsTests {
    @Test
    func testChainsAll() {
        let wallet = Wallet.mock(accounts: [
            .mock(chain: .bitcoin),
            .mock(chain: .doge),
            .mock(chain: .ethereum)
        ])

        let result = wallet.chains
        let expectedChains: [Chain] = [.bitcoin, .ethereum, .doge]
        #expect(result == expectedChains)
    }

    @Test
    func testChainsWithTokens() {
        let wallet = Wallet.mock(accounts: [
            .mock(chain: .bitcoin),
            .mock(chain: .doge),
            .mock(chain: .ethereum)
        ])

        let result = wallet.chainsWithTokens
        let expectedChains: [Chain] = [.ethereum]
        #expect(result == expectedChains)
    }

    @Test
    func testChainSorting() {
        let wallet = Wallet.mock(accounts: [
            .mock(chain: .doge),
            .mock(chain: .ethereum),
            .mock(chain: .bitcoin)
        ])

        let result = wallet.chains
        let expectedChains: [Chain] = [.bitcoin, .ethereum, .doge]
        #expect(result == expectedChains)
    }
}
