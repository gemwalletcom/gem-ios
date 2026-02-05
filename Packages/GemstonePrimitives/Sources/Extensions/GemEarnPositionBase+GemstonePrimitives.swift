// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemEarnPositionBase {
    public func map() -> EarnPositionBase {
        EarnPositionBase(
            assetId: try! AssetId(id: assetId),
            state: state.map(),
            balance: balance,
            shares: shares,
            rewards: rewards,
            unlockDate: unlockDate.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            positionId: positionId,
            providerId: providerId
        )
    }
}

extension GemEarnPositionState {
    public func map() -> EarnPositionState {
        switch self {
        case .active: .active
        case .pending: .pending
        case .inactive: .inactive
        case .activating: .activating
        case .deactivating: .deactivating
        case .awaitingWithdrawal: .awaitingWithdrawal
        }
    }
}
