// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit

struct Wallet_PrimitivesTests {
    @Test
    func canSign() {
        #expect(Wallet.mock(type: .multicoin).canSign == true)
        #expect(Wallet.mock(type: .view).canSign == false)
    }

    @Test
    func walletIdType() {
        #expect(Wallet.mock(type: .multicoin, accounts: [.mock(address: "0x123")]).walletIdType == "multicoin_0x123")
        #expect(Wallet.mock(type: .single, accounts: [.mock(chain: .ethereum, address: "0x456")]).walletIdType == "single_ethereum_0x456")
        #expect(Wallet.mock(type: .privateKey, accounts: [.mock(chain: .bitcoin, address: "bc1abc")]).walletIdType == "privateKey_bitcoin_bc1abc")
        #expect(Wallet.mock(type: .view, accounts: [.mock(chain: .ethereum, address: "0x789")]).walletIdType == "view_ethereum_0x789")
    }
}
