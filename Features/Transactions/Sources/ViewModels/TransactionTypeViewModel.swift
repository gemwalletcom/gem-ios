// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct TransactionTypeViewModel {
    private let type: TransactionType

    init(type: TransactionType) {
        self.type = type
    }

    var title: String {
        switch type {
        case .transfer, .transferNFT: Localized.Transfer.title
        case .swap: Localized.Wallet.swap
        case .tokenApproval: Localized.Transfer.Approve.title
        case .stakeDelegate: Localized.Transfer.Stake.title
        case .stakeUndelegate: Localized.Transfer.Unstake.title
        case .stakeRedelegate: Localized.Transfer.Redelegate.title
        case .stakeRewards: Localized.Transfer.Rewards.title
        case .stakeWithdraw: Localized.Transfer.Withdraw.title
        case .assetActivation: Localized.Transfer.ActivateAsset.title
        }
    }
}
