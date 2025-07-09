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
    
    public func updateTokens(
        deviceId: String,
        wallet: Wallet,
        fromTimestamp: Int
    ) async throws -> AsyncStream<AssetUpdate> {
        let tokenAddressIds: [(AssetId, String)] = try await assetsService
            .getAssetsByDeviceId(
                deviceId: deviceId,
                walletIndex: wallet.index.asInt,
                fromTimestamp: fromTimestamp
            )
            .compactMap {
                if let address = try? wallet.account(for: $0.chain).address, $0.type == .token {
                    return ($0, address)
                }
                return nil
            }

        return updateBalances(tokenAddressIds, wallet)
    }

    public func updateCoins(wallet: Wallet) -> AsyncStream<AssetUpdate> {
        guard wallet.isMultiCoins else { return AsyncStream.just(AssetUpdate(walletId: wallet.walletId, assetIds: [])) }
        
        let coinAddressIds: [(AssetId, String)] = wallet.accounts.map {
            ($0.chain.assetId, $0.address)
        }

        return updateBalances(coinAddressIds, wallet)
    }
    
    // MARK: - Private methods
    
    private func updateBalances(_ assetAddressIds: [(AssetId, String)], _ wallet: Wallet) -> AsyncStream<AssetUpdate> {
        AsyncStream { continuation in
            let task = Task {
                await withTaskGroup(of: [AssetBalanceChange].self) { group in
                    for (asset, address) in assetAddressIds {
                        group.addTask {
                            do {
                                return try await self.balanceService.updateBalance(
                                    walletId: wallet.id,
                                    asset: asset,
                                    address: address
                                )
                            } catch {
                                NSLog("Error fetching token balance: \(error)")
                                return []
                            }
                        }
                    }
                    
                    for await change in group {
                        continuation.yield(
                            AssetUpdate(
                                walletId: wallet.walletId,
                                assetIds: change.filter { $0.type.available.or(.zero) > 0}.map { $0.assetId }
                            )
                        )
                    }
                    
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
