// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Testing

struct WalletIdentifierTests {
    @Test
    func id() {
        #expect(WalletIdentifier.multicoin(address: "0x123").id == "multicoin_0x123")
        #expect(WalletIdentifier.single(chain: .ethereum, address: "0x456").id == "single_ethereum_0x456")
    }

    @Test
    func walletTypeAndChain() {
        #expect(WalletIdentifier.multicoin(address: "0x123").walletType == .multicoin)
        #expect(WalletIdentifier.multicoin(address: "0x123").chain == nil)
        #expect(WalletIdentifier.single(chain: .ethereum, address: "0x456").chain == .ethereum)
    }

    @Test
    func fromId() throws {
        #expect(try WalletIdentifier.from(id: "multicoin_0x123") == .multicoin(address: "0x123"))
        #expect(try WalletIdentifier.from(id: "single_ethereum_0x456") == .single(chain: .ethereum, address: "0x456"))
        #expect(throws: Error.self) { try WalletIdentifier.from(id: "invalid") }
    }

    @Test
    func fromIdAndBackToId() throws {
        let types: [WalletIdentifier] = [
            .multicoin(address: "0xabc"),
            .single(chain: .ethereum, address: "0x123"),
            .privateKey(chain: .bitcoin, address: "bc1test"),
            .view(chain: .solana, address: "soladdr"),
        ]
        for type in types {
            #expect(try WalletIdentifier.from(id: type.id) == type)
        }
    }
}
