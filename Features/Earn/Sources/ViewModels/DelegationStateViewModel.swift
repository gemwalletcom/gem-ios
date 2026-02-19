// Copyright (c). Gem Wallet. All rights reserved.

import Localization
import Primitives

public struct DelegationStateViewModel {

    public let state: DelegationState

    public init(state: DelegationState) {
        self.state = state
    }

    public var title: String {
        switch state {
        case .active: Localized.Stake.active
        case .pending: Localized.Stake.pending
        case .inactive: Localized.Stake.inactive
        case .activating: Localized.Stake.activating
        case .deactivating: Localized.Stake.deactivating
        case .awaitingWithdrawal: Localized.Stake.awaitingWithdrawal
        }
    }
}
