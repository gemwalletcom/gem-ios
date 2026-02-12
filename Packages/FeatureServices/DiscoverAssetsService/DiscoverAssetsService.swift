// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import ChainService
import BalanceService

public struct DiscoverAssetsService: Sendable {
    private let balanceService: BalanceService
    private let assetsService: any GemAPIAssetsListService

    public init(
        balanceService: BalanceService,
        assetsService: any GemAPIAssetsListService = GemAPIService.shared
    ) {
        self.balanceService = balanceService
        self.assetsService = assetsService
    }
    
    public func getAssets(
        wallet: Wallet,
        fromTimestamp: Int
    ) async throws -> [AssetId] {
        try await assetsService
            .getDeviceAssets(
                walletId: wallet.id,
                fromTimestamp: fromTimestamp
            )
    }
}
