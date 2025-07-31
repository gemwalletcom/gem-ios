// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import BalanceService
import StakeService
import NFTService
import Primitives

struct TransactionStateUpdatePostJob: Sendable {
    private let transactionStore: TransactionStore
    private let balanceUpdater: any BalancerUpdater
    private let stakeService: StakeService
    private let nftService: NFTService

    init(
        transactionStore: TransactionStore,
        balanceUpdater: any BalancerUpdater,
        stakeService: StakeService,
        nftService: NFTService
    ) {
        self.transactionStore = transactionStore
        self.balanceUpdater = balanceUpdater
        self.stakeService = stakeService
        self.nftService = nftService
    }

    func process(wallet: Wallet, transaction: Transaction) async throws {
        Task {
            await balanceUpdater.updateBalance(
                for: wallet,
                assetIds: (transaction.assetIds + [transaction.feeAssetId]).unique()
            )
        }

        switch transaction.type {
        case .stakeDelegate, .stakeUndelegate, .stakeRewards, .stakeRedelegate, .stakeWithdraw:
            for assetIdentifier in transaction.assetIds {
                Task {
                    try await stakeService.update(
                        walletId: wallet.id,
                        chain: assetIdentifier.chain,
                        address: transaction.from
                    )
                }
            }
        case .transferNFT:
            Task {
                // TODO: implement nftService.update when ready
            }
        default:
            break
        }
    }
}
