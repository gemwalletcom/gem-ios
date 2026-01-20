// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import PrimitivesTestKit
import Testing

struct Wallet_PrimitivesTests {
    @Test
    func canSign() {
        #expect(Wallet.mock(type: .multicoin).canSign == true)
        #expect(Wallet.mock(type: .view).canSign == false)
    }

    @Test
    func walletIdentifier() throws {
        #expect(throws: Error.self) {
            try Wallet
                .mock(type: .multicoin, accounts: [.mock(chain: .bitcoin, address: "0x123")])
                .walletIdentifier()
        }
        #expect(try Wallet.mock(type: .multicoin, accounts: [.mock(chain: .ethereum, address: "0x123")]).walletIdentifier() == .multicoin(address: "0x123"))
        #expect(try Wallet.mock(type: .single, accounts: [.mock(chain: .ethereum, address: "0x456")]).walletIdentifier() == .single(chain: .ethereum, address: "0x456"))
        #expect(try Wallet.mock(type: .privateKey, accounts: [.mock(chain: .bitcoin, address: "bc1abc")]).walletIdentifier() == .privateKey(chain: .bitcoin, address: "bc1abc"))
        #expect(try Wallet.mock(type: .view, accounts: [.mock(chain: .ethereum, address: "0x789")]).walletIdentifier() == .view(chain: .ethereum, address: "0x789"))
    }
}
