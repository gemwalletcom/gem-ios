// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public protocol EarnBalanceServiceable: Sendable {
    func updatePositions(walletId: WalletId, assetId: AssetId, address: String) async
}

public struct EarnBalanceService: EarnBalanceServiceable {
    private let earnStore: EarnStore
    private let earnService: any EarnServiceType

    public init(
        earnStore: EarnStore,
        earnService: any EarnServiceType
    ) {
        self.earnStore = earnStore
        self.earnService = earnService
    }

    public func updatePositions(walletId: WalletId, assetId: AssetId, address: String) async {
        for provider in EarnProvider.allCases {
            do {
                let position = try await earnService.fetchPosition(
                    provider: provider,
                    asset: assetId,
                    walletAddress: address
                )
                try earnStore.updatePosition(position, walletId: walletId)
            } catch {
                // Asset may not have earn support for this provider - skip silently
            }
        }
    }
}
