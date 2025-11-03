// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import WalletSessionServiceTestKit
import PrimitivesTestKit
import Primitives

@testable import WalletSessionService

struct WalletSessionServiceTests {
    @Test
    func setCurrentReturnsWalletId() throws {
        let wallet = Wallet.mock(index: 1)
        let service = try WalletSessionService.mock(wallet: wallet)

        #expect(service.setCurrent(index: 1) == wallet.walletId)
        #expect(service.currentWalletId == wallet.walletId)
    }

    @Test
    func setCurrentReturnsNil() throws {
        let service = try WalletSessionService.mock(wallet: .mock(index: 1))

        #expect(service.setCurrent(index: 999) == .none)
        #expect(service.currentWalletId == .none)
    }
}
