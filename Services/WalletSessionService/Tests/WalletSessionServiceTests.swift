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

        try walletStore.addWallet(.mock(id: "Wallet1", name: "Wallet 1"))
        try walletStore.addWallet(.mock(id: "Wallet2", name: "Wallet 2"))

        service.setCurrent(walletId: WalletId.mock(id: "Wallet1"))

        #expect(service.currentWallet != nil)
        #expect(service.currentWallet?.walletId.id == "Wallet1")
        #expect(service.currentWalletId?.id == "Wallet1")
        #expect(service.wallets.count == 2)
    }

    @Test
    func testSetCurrentIndexUpdates() throws {
        let walletStore = WalletStore.mock()
        let service = WalletSessionService.mock(
            store: walletStore
        )

        try walletStore.addWallet(.mock(id: "Wallet1", name: "Wallet 1"))
        try walletStore.addWallet(.mock(id: "Wallet2", name: "Wallet 2"))

        service.setCurrent(index: 2)

        #expect(service.currentWallet != nil)
        #expect(service.currentWallet?.walletId.id == "Wallet2")
        #expect(service.currentWalletId?.id == "Wallet2")
        #expect(service.wallets.count == 2)
    }

    @Test
    func testCurrentWalletUpdates() throws {
        let walletStore = WalletStore.mock()
        let service = WalletSessionService.mock(
            store: walletStore
        )
        #expect(service.currentWallet == nil)

        try walletStore.addWallet(.mock(id: "Wallet1", name: "Wallet 1"))
        try walletStore.addWallet(.mock(id: "Wallet2", name: "Wallet 2"))

        #expect(service.currentWallet == nil)

        service.setCurrent(walletId: WalletId.mock(id: "Wallet1"))

        #expect(service.currentWalletId == WalletId.mock(id: "Wallet1"))

        service.setCurrent(walletId: WalletId.mock(id: "Wallet2"))

        #expect(service.currentWalletId == WalletId.mock(id: "Wallet2"))
    }
}
