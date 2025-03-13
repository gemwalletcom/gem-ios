import Testing
import Primitives
import Preferences
import Store
import PreferencesTestKit
import StoreTestKit
import PrimitivesTestKit
import WalletSessionServiceTeskKit

@testable import WalletSessionService

struct WalletSessionServiceTests {
    private let wallet1: Wallet = .mock(id: "Wallet1", name: "Wallet 1")
    private let wallet2: Wallet = .mock(id: "Wallet2", name: "Wallet 2")

    @Test
    func testCurrentWalletNilWhenPreferenceIsNil() {
        let service = WalletSessionService.mock()
        #expect(service.wallets.isEmpty == true)
        #expect(service.currentWallet == nil)
        #expect(service.currentWalletId == nil)
    }

    @Test
    func testCurrentWalletReturnsCorrectWallet() throws {
        let walletStore = WalletStore.mock()
        let service = WalletSessionService.mock(
            store: walletStore
        )

        try walletStore.addWallet(wallet1)
        try walletStore.addWallet(wallet2)

        service.setCurrent(walletId: wallet1.walletId)

        #expect(service.currentWallet != nil)
        #expect(service.currentWallet?.id == wallet1.id)
        #expect(service.currentWalletId == wallet1.walletId)
        #expect(service.wallets.count == 2)
    }

    @Test
    func testSetCurrentIndexUpdates() throws {
        let walletStore = WalletStore.mock()
        let service = WalletSessionService.mock(
            store: walletStore
        )

        try walletStore.addWallet(wallet1)
        try walletStore.addWallet(wallet2)

        service.setCurrent(index: 2)

        #expect(service.currentWallet != nil)
        #expect(service.currentWallet?.id == wallet2.id)
        #expect(service.currentWalletId == wallet2.walletId)
        #expect(service.wallets.count == 2)
    }

    @Test
    func testCurrentWalletUpdates() throws {
        let walletStore = WalletStore.mock()
        let service = WalletSessionService.mock(
            store: walletStore
        )
        #expect(service.currentWallet == nil)

        try walletStore.addWallet(wallet1)
        try walletStore.addWallet(wallet2)

        #expect(service.currentWallet == nil)

        service.setCurrent(walletId: wallet1.walletId)

        #expect(service.currentWalletId == wallet1.walletId)

        service.setCurrent(walletId: wallet2.walletId)

        #expect(service.currentWalletId == wallet2.walletId)
    }
}
