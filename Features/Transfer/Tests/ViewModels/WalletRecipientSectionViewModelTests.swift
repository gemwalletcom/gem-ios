// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
@testable import Transfer

struct WalletRecipientSectionViewModelTests {

    @Test
    func listItems() {
        let wallet = Wallet.mock(
            name: "My Wallet",
            type: .multicoin,
            accounts: [.mock(chain: .bitcoin, address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")]
        )
        let model = WalletRecipientSectionViewModel(wallets: [wallet], section: .wallets, chain: .bitcoin)

        #expect(model.listItems.count == 1)
        #expect(model.listItems.first?.title == "My Wallet")
        #expect(model.listItems.first?.subtitle == "bc1qxy...x0wlh")
        #expect(model.listItems.first?.value.name == "My Wallet")
        #expect(model.listItems.first?.value.address == "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")
        #expect(model.listItems.first?.value.memo == nil)
    }
}
