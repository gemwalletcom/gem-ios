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
    func process(transactionWallet: TransactionWallet) async throws {
        Task {
            await balanceUpdater.updateBalance(
                for: transactionWallet.wallet,
                assetIds: transactionWallet.assetIdentifiers
            )
        }
        
        switch transactionWallet.type {
        case .stakeDelegate, .stakeUndelegate, .stakeRewards:
            for assetIdentifier in transactionWallet.assetIdentifiers {
                Task {
                    try await stakeService.update(
                        walletId: transactionWallet.wallet.id,
                        chain: assetIdentifier.chain,
                        address: transactionWallet.transaction.from
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
