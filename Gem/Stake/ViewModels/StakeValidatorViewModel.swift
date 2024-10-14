// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

struct StakeValidatorViewModel {
    let validator: DelegationValidator
    
    let aprFormatter = CurrencyFormatter(type: .percentSignLess)
    
    var name: String {
        validator.name
    }
    
    var aprText: String {
        if validator.apr > 0 {
            return Localized.Stake.apr(aprFormatter.string(validator.apr))
        }
        return .empty
    }
}
