// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum FilterType: String, CaseIterable {
    case transfers
    case smartContract
    case swaps
    case stake
    case others
    
    public init(transactionType: TransactionType) {
        switch transactionType {
        case .transfer, .transferNFT:
            self = .transfers
        case .smartContractCall:
            self = .smartContract
        case .swap, .tokenApproval:
            self = .swaps
        case .stakeDelegate, .stakeUndelegate, .stakeRewards, .stakeRedelegate, .stakeWithdraw:
            self = .stake
        case .assetActivation:
            self = .others
        }
    }

    public var filters: [TransactionType] {
        switch self {
        case .transfers: [.transfer, .transferNFT]
        case .smartContract: [.smartContractCall]
        case .swaps: [.swap, .tokenApproval]
        case .stake: [.stakeDelegate, .stakeUndelegate, .stakeRewards, .stakeRedelegate, .stakeWithdraw]
        case .others: [.assetActivation]
        }
    }
}

extension FilterType: Identifiable {
    public var id: String { rawValue }
}
