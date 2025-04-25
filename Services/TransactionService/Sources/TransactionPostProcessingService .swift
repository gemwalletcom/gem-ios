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

    // Once transaction is completed, update nessesary states internally, balances, stakes, nft ownership
    func process(transaction: Transaction) async throws {
        let assetIdentifiers = (transaction.assetIds + [transaction.feeAssetId]).unique()
        let walletIdentifiers = try transactionStore.getWalletIds(for: transaction.id)

        for walletIdentifier in walletIdentifiers {
            for assetIdentifier in assetIdentifiers {
                Task {
                    try await balanceUpdater.updateBalance(
                        walletId: walletIdentifier,
                        asset: assetIdentifier,
                        address: transaction.from
                    )
                }

                switch transaction.type {
                case .stakeDelegate, .stakeUndelegate, .stakeRewards:
                    Task {
                        try await stakeService.update(
                            walletId: walletIdentifier,
                            chain: assetIdentifier.chain,
                            address: transaction.from
                        )
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
    }
}
