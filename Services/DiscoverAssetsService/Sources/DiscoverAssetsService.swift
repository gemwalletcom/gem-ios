// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import ChainService
import BalanceService

public struct DiscoverAssetsService: Sendable {
    private let balanceService: BalanceService
    private let assetsService: any GemAPIAssetsListService
    private let chainServiceFactory: ChainServiceFactory

    public init(
        balanceService: BalanceService,
        assetsService: any GemAPIAssetsListService = GemAPIService.shared,
        chainServiceFactory: ChainServiceFactory
    ) {
        self.balanceService = balanceService
        self.assetsService = assetsService
        self.chainServiceFactory = chainServiceFactory
    }

    public func updateTokens(
        deviceId: String,
        wallet: Wallet,
        fromTimestamp: Int
    ) async throws -> [AssetUpdate] {
        let assetIds = try await assetsService.getAssetsByDeviceId(
            deviceId: deviceId,
            walletIndex: wallet.index.asInt,
            fromTimestamp: fromTimestamp
        )

        var updates: [AssetUpdate] = []
        await withTaskGroup(of: AssetUpdate?.self) { group in
            for assetId in assetIds {
                if let address = try? wallet.account(for: assetId.chain).address,
                   assetId.type == .token {
                    group.addTask {
                        do {
                            let balance = try await self.balanceService.getBalance(assetId: assetId, address: address)
                            if balance.balance.available > 0 {
                                return AssetUpdate(wallet: wallet, assets: [assetId.identifier])
                            }
                        } catch {
                            NSLog("Error fetching tooken balance: \(error)")
                        }
                        return nil
                    }
                }
            }

            for await update in group {
                if let update = update {
                    updates.append(update)
                }
            }
        }

        return updates
    }

    public func updateCoins(wallet: Wallet) async -> [AssetUpdate] {
        guard wallet.isMultiCoins else { return [] }

        var updates: [AssetUpdate] = []
        await withTaskGroup(of: AssetUpdate?.self) { group in
            for account in wallet.accounts {
                let service = chainServiceFactory.service(for: account.chain)
                group.addTask {
                    do {
                        let balance = try await service.coinBalance(for: account.address)
                        if balance.balance.available > 0 {
                            return AssetUpdate(wallet: wallet, assets: [account.chain.id])
                        }
                    } catch {
                        NSLog("Error fetching coin balance: \(error)")
                    }
                    return nil
                }
            }

            for await update in group {
                if let update = update {
                    updates.append(update)
                }
            }
        }
        return updates
    }
}
