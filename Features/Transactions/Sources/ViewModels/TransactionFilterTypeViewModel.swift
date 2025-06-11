// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct TransactionFilterTypeViewModel {
    private let type: TransactionFilterType

    init(type: TransactionFilterType) {
        self.type = type
    }

    var title: String {
        switch type {
        case .transfers: Localized.Transfer.title
        case .smartContract: Localized.Transfer.SmartContract.title
        case .swaps: Localized.Wallet.swap
        case .stake: Localized.Transfer.Stake.title
        case .others: Localized.Transfer.Other.title
        }
    }
    
    var filters: [TransactionType] {
        switch type {
        case .transfers: [.transfer, .transferNFT]
        case .smartContract: [.smartContractCall]
        case .swaps: [.swap, .tokenApproval]
        case .stake: [.stakeDelegate, .stakeUndelegate, .stakeRewards, .stakeRedelegate, .stakeWithdraw]
        case .others: [.assetActivation]
        }
    }
}
