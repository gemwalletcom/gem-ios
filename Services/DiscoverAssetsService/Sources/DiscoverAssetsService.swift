// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Combine
import GemAPI
import ChainService
import BalanceService

public struct AssetUpdate {
    public let wallet: Wallet
    public let assets: [String]
}

public struct DiscoverAssetsService: @unchecked Sendable {
    private let balanceService: BalanceService
    private let assetsService: any GemAPIAssetsListService
    private let chainServiceFactory: ChainServiceFactory

    // TODO: - omit combine and cancellables to confirm Sendable
    private var assetSubject = PassthroughSubject<AssetUpdate, Never>()

    public init(
        balanceService: BalanceService,
        assetsService: any GemAPIAssetsListService = GemAPIService.shared,
        chainServiceFactory: ChainServiceFactory
    ) {
        self.balanceService = balanceService
        self.assetsService = assetsService
        self.chainServiceFactory = chainServiceFactory
    }

    public func updateTokens(deviceId: String, wallet: Wallet, fromTimestamp: Int) async throws {
        let assetIds = try await assetsService.getAssetsByDeviceId(
            deviceId: deviceId,
            walletIndex: wallet.index.asInt,
            fromTimestamp: fromTimestamp
        )

        for assetId in assetIds {
            if let address = try? wallet.account(for: assetId.chain).address, assetId.type == .token {
                Task {
                    let balance = try await balanceService.getBalance(assetId: assetId, address: address)
                    if balance.balance.available > 0 {
                        assetSubject.send(AssetUpdate(wallet: wallet, assets: [assetId.identifier]))
                    }
                }
            }
        }
    }

    public func updateCoins(wallet: Wallet) async {
        guard wallet.isMultiCoins else {
            return
        }
        for account in wallet.accounts {
            let service = chainServiceFactory.service(for: account.chain)
            Task {
                let balance = try await service.coinBalance(for: account.address)
                if balance.balance.available > 0 {
                    assetSubject.send(AssetUpdate(wallet: wallet, assets: [account.chain.id]))
                }
            }
        }
    }

    public func observeAssets() -> AnyPublisher<AssetUpdate, Never> {
        return assetSubject.eraseToAnyPublisher()
    }
}
