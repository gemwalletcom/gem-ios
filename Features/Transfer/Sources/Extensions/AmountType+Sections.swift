// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

extension AmountType {
    var optionsSectionTitle: String? {
        switch self {
        case .stake, .stakeUnstake, .stakeRedelegate, .stakeWithdraw:
            Localized.Stake.validator
        case .freeze:
            Localized.Stake.resource
        case .perpetual, .transfer, .deposit, .withdraw:
            nil
        }
    }
}
