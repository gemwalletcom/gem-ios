// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Preferences
import PreferencesTestKit
import Primitives
import Testing

@testable import ExplorerService

final class ExplorerServiceTests {
    @Test
    func testExplorerService() {
        let service = ExplorerService(preferences: ExplorerPreferences.mock())
        let chain = Chain.bitcoin
        let hash = "f9c7f0f5d34ad038cdb097902ea66a53f53bd34709569fd9a02b761288470ee2"

        #expect(service.transactionUrl(chain: chain, hash: hash, swapProvider: .none).name == "Blockchair")
        #expect(service.transactionUrl(chain: chain, hash: hash, swapProvider: .none).link == "https://blockchair.com/bitcoin/transaction/\(hash)")

        service.set(chain: chain, name: "Mempool")
        #expect(service.transactionUrl(chain: chain, hash: hash, swapProvider: .none).name == "Mempool")
    }

    @Test
    func testTransactionSwapUrl() {
        let service = ExplorerService(preferences: ExplorerPreferences.mock())
        let chain = Chain.solana
        let hash = "f9c7f0f5d34ad038cdb097902ea66a53f53bd34709569fd9a02b761288470ee2"
        
        #expect(service.transactionUrl(chain: chain, hash: hash, swapProvider: SwapProvider.mayan.rawValue).name == "Mayan Explorer")
        #expect(service.transactionUrl(chain: chain, hash: hash, swapProvider: SwapProvider.mayan.rawValue).url == URL(string: "https://explorer.mayan.finance/tx/f9c7f0f5d34ad038cdb097902ea66a53f53bd34709569fd9a02b761288470ee2")!)
    }
}
