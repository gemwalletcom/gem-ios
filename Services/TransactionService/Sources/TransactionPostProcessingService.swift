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
        for assetIdentifier in transactionWallet.assetIdentifiers {
            guard let address = transactionWallet.address(for: assetIdentifier) else {
                NSLog("TransactionStateUpdatePostJob: no address for transaction: \(transactionWallet)")
                continue
            }

            Task {
                try await balanceUpdater.updateBalance(
                    walletId: transactionWallet.wallet.id,
                    asset: assetIdentifier,
                    address: address
                )
            }

            switch transactionWallet.type {
            case .stakeDelegate, .stakeUndelegate, .stakeRewards:
                Task {
                    try await stakeService.update(
                        walletId: transactionWallet.wallet.id,
                        chain: assetIdentifier.chain,
                        address: address
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
