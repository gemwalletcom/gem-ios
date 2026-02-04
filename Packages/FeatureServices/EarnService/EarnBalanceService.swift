// Copyright (c). Gem Wallet. All rights reserved.

import AssetsService
import BigInt
import Formatters
import Foundation
import Primitives
import Store

public protocol EarnBalanceServiceable: Sendable {
    func updatePositions(walletId: WalletId, assetId: AssetId, address: String) async
}

public struct EarnBalanceService: EarnBalanceServiceable {
    private let assetsService: AssetsService
    private let balanceStore: BalanceStore
    private let earnStore: EarnStore
    private let earnService: any EarnServiceType
    private let formatter = ValueFormatter(style: .full)

    public init(
        assetsService: AssetsService,
        balanceStore: BalanceStore,
        earnStore: EarnStore,
        earnService: any EarnServiceType
    ) {
        self.assetsService = assetsService
        self.balanceStore = balanceStore
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

        updateEarnBalance(walletId: walletId, assetId: assetId)
    }

    private func updateEarnBalance(walletId: WalletId, assetId: AssetId) {
        do {
            let positions = try earnStore.getPositions(walletId: walletId, assetId: assetId)
            let total = positions
                .compactMap { BigInt($0.balance) }
                .reduce(.zero, +)
            guard let asset = try assetsService.getAssets(for: [assetId]).first else {
                throw AnyError("asset not found")
            }
            let amount = (try? formatter.double(from: total, decimals: asset.decimals.asInt)) ?? 0
            let update = UpdateBalance(
                assetId: assetId,
                type: .earn(UpdateEarnBalance(balance: UpdateBalanceValue(value: total.description, amount: amount))),
                updatedAt: .now,
                isActive: true
            )
            try balanceStore.updateBalances([update], for: walletId)
        } catch {
            debugLog("earn balance update error: \(error)")
        }
    }
}
