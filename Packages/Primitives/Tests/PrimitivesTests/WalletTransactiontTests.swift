// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
@testable import Primitives

struct WalletTransactionTests {
    private static let sol = AssetId.mock(.solana)
    private static let sui = AssetId.mock(.sui)
    private static let btc = AssetId.mock()

    private static let metadata = TransactionMetadata.swap(
        .mock(
            fromAsset: Self.sol,
            toAsset: Self.sui
        )
    )

    @Test
    func transferFromAddress() throws {
        #expect(
            TransactionWallet(
                transaction: .mock(type: .transfer, assetId: Self.btc, from: "sender"),
                wallet: .mock()
            ).address(for: Self.btc)
            == "sender"
        )
    }

    @Test
    func swapFromAddress() throws {
        #expect(
            TransactionWallet(
                transaction: .mock(type: .swap, assetId: Self.sol, from: "solSender", metadata: Self.metadata),
                wallet: .mock()
            ).address(for: Self.sol)
            == "solSender"
        )
    }

    @Test
    func swapToAddress() throws {
        #expect(
            TransactionWallet(
                transaction: .mock(type: .swap, assetId: Self.sol, metadata: Self.metadata),
                wallet: .mock(accounts: [.mock(chain: .sui, address: "walletSui")])
            ).address(for: Self.sui)
            == "walletSui"
        )
    }

    @Test
    func swapUnknownChainAddress() throws {
        #expect(
            TransactionWallet(
                transaction: .mock(type: .swap, assetId: Self.sol, metadata: Self.metadata),
                wallet: .mock()
            ).address(for: Self.btc)
            == nil
        )
    }
}
