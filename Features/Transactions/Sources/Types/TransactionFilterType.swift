// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum TransactionFilterType: Int, CaseIterable {
    case transfers
    case swaps
    case stake
    case smartContract
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
}

extension TransactionFilterType: Identifiable {
    public var id: String { rawValue.description }
}

extension TransactionFilterType: Comparable {
    public static func < (lhs: TransactionFilterType, rhs: TransactionFilterType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
