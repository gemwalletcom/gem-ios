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

        return await withTaskGroup(of: AssetUpdate?.self) { group in
            for (token, address) in tokenAddressIds {
                group.addTask {
                    do {
                        let balance = try await self.balanceService.getBalance(assetId: token, address: address)
                        if balance.balance.available > 0 {
                            return AssetUpdate(walletId: wallet.walletId, assets: [token.identifier])
                        }
                    } catch {
                        NSLog("Error fetching token balance: \(error)")
                    }
                    return nil
                }
            }

            var updates = [AssetUpdate]()
            for await update in group {
                if let update = update {
                    updates.append(update)
                }
            }
            return updates
        }
    }

    public func updateCoins(wallet: Wallet) async -> [AssetUpdate] {
        guard wallet.isMultiCoins else { return [] }

        return await withTaskGroup(of: AssetUpdate?.self) { group in
            for account in wallet.accounts {
                let service = self.chainServiceFactory.service(for: account.chain)
                group.addTask {
                    do {
                        let balance = try await service.coinBalance(for: account.address)
                        if balance.balance.available > 0 {
                            return AssetUpdate(walletId: wallet.walletId, assets: [account.chain.id])
                        }
                    } catch {
                        NSLog("Error fetching coin balance: \(error)")
                    }
                    return nil
                }
            }

            var updates: [AssetUpdate] = []
            for await update in group {
                if let update = update {
                    updates.append(update)
                }
            }
            return updates
        }
    }
}
