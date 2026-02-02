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
        deviceId: String,
        wallet: Wallet,
        fromTimestamp: Int
    ) async throws -> [AssetId] {
        try await assetsService
            .getDeviceAssets(
                deviceId: deviceId,
                walletId: wallet.walletIdentifier().id,
                fromTimestamp: fromTimestamp
            )
    }
}
