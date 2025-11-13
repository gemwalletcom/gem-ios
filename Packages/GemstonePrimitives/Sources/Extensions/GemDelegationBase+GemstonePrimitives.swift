// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemDelegationState {
    public func map() -> DelegationState {
        switch self {
        case .active: return .active
        case .pending: return .pending
        case .inactive: return .inactive
        case .activating: return .activating
        case .deactivating: return .deactivating
        case .awaitingWithdrawal: return .awaitingWithdrawal
        }
    }
}

extension DelegationState {
    public func map() -> GemDelegationState {
        switch self {
        case .active: return .active
        case .pending: return .pending
        case .inactive: return .inactive
        case .activating: return .activating
        case .deactivating: return .deactivating
        case .awaitingWithdrawal: return .awaitingWithdrawal
        }
    }
}

extension GemDelegationBase {
    public func map() throws -> DelegationBase {
        DelegationBase(
            assetId: try AssetId(id: assetId),
            state: state.map(),
            balance: balance,
            shares: shares,
            rewards: rewards,
            completionDate: completionDate.map { Date(timeIntervalSince1970: TimeInterval($0)) },
            delegationId: delegationId,
            validatorId: validatorId
        )
    }
}

extension DelegationBase {
    public func map() -> GemDelegationBase {
        GemDelegationBase(
            assetId: assetId.identifier,
            state: state.map(),
            balance: balance,
            shares: shares,
            rewards: rewards,
            completionDate: completionDate.map { Int64($0.timeIntervalSince1970) },
            delegationId: delegationId,
            validatorId: validatorId
        )
    }
}
