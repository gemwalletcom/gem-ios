// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AddressResolver {
    static func resolve(
        for assetId: AssetId,
        in transaction: Transaction
    ) -> String? {
        switch transaction.type {
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
        case .swap:
            guard case let .swap(meta) = transaction.metadata,
                  meta.fromAsset.chain == assetId.chain || meta.toAsset.chain == assetId.chain
            else { return nil }
            return assetId.chain == meta.fromAsset.chain ? transaction.from : transaction.to
        }
    }
}
