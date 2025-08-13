// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import ChainService
import BalanceService
import ServicePrimitives
import Preferences

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
        
        let coinAddressIds: [(AssetId, String)] = wallet.accounts.excludeDefaultAccounts().map {
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

extension Array where Element == Account {
    func excludeDefaultAccounts() -> [Account] {
        filter { account in
            !AssetConfiguration.enabledByDefault.contains(where: { $0.chain == account.chain })
        }
    }
}

extension DiscoverAssetsService: DiscoveryAssetsProcessing {
    public func discoverAssets(for walletId: WalletId, preferences: WalletPreferences) async throws {
        // This would typically use the wallet to discover assets
        // For now, we'll implement a placeholder that calls the existing updateCoins method
        // This would need to be properly implemented based on business requirements
        
        // Create a minimal wallet from walletId for compatibility
        let wallet = Wallet(id: walletId.id, name: "", index: 0, type: .multicoin, accounts: [])
        let _ = updateCoins(wallet: wallet)
    }
}
