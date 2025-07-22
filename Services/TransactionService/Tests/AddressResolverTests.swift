// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit
import Primitives
@testable import TransactionService

struct AddressResolverTests {
    @Test
    func transferResolvesFrom() throws {
        #expect(
            AddressResolver.resolve(
                for: .mock(.bitcoin),
                in: Transaction.mock(type: .transfer, from: "from", to: "to")
            ) == "from"
        )
    }

    @Test
    func swapResolvesFromChain() throws {
        let metadata = TransactionMetadata.swap(
            .mock(
                fromAsset: .mock(.solana),
                toAsset: .mock(.sui)
            )
        )
        #expect(
            AddressResolver.resolve(
                for: .mockSolana(),
                in: .mock(type: .swap, from: "solFrom", metadata: metadata)
            ) == "solFrom")
    }

    @Test
    func swapResolvesToChain() throws {
        let metadata = TransactionMetadata.swap(
            .mock(
                fromAsset: .mock(.solana),
                toAsset: .mock(.sui)
            )
        )
        #expect(
            AddressResolver.resolve(
                for: .mock(.solana),
                in: .mock(type: .swap, from: "solFrom", to: "suiTo", metadata: metadata)
            ) == "suiTo")
    }

    @Test
    func swapUnknownChainReturnsNil() throws {
        let metadata = TransactionMetadata.swap(
            .mock(
                fromAsset: .mock(.solana),
                toAsset: .mock(.sui)
            )
        )
        #expect(
            AddressResolver.resolve(
                for: .mock(),
                in: Transaction.mock(type: .swap, from: "from", to: "to", metadata: metadata)
            ) == nil
        )

    }
}
