// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Formatters

public struct StakeValidatorViewModel {
    
    public let validator: DelegationValidator
    public let aprFormatter = CurrencyFormatter.percentSignLess
    
    public init(validator: DelegationValidator) {
        self.validator = validator
    }
    
    public var name: String {
        switch validator.providerType {
        case .earn:
            YieldProvider(rawValue: validator.id)?.displayName ?? validator.name
        case .stake:
            validator.name
        }
    }
    
    public var aprText: String {
        if validator.apr > 0 {
            return Localized.Stake.apr(aprFormatter.string(validator.apr))
        }
        return .empty
    }
}
