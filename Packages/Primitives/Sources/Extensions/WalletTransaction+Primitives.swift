// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension TransactionWallet {
    var assetIdentifiers: [AssetId] {
        (transaction.assetIds + [transaction.feeAssetId]).unique()
    }

    var assetId: AssetId {
        transaction.assetId
    }

    var type: TransactionType {
        transaction.type
    }

    func address(for asset: AssetId) -> String? {
        switch transaction.type {
        case .swap:
            guard case let .swap(meta) = transaction.metadata else { return nil }
            if asset.chain == meta.fromAsset.chain { return transaction.from }
            if asset.chain == meta.toAsset.chain {
                return try? wallet.account(for: meta.toAsset.chain).address
            }
            return nil
        case .transfer,
                .transferNFT,
                .tokenApproval,
                .stakeDelegate,
                .stakeUndelegate,
                .stakeRewards,
                .stakeWithdraw,
                .assetActivation,
                .smartContractCall,
                .stakeRedelegate:
            return transaction.from
        }
    }
}
