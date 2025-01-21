// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Components

public struct ValidatorDelegationView: View {
    
    private let delegation: StakeDelegationViewModel
    
    public init(delegation: StakeDelegationViewModel) {
        self.delegation = delegation
    }
    
    public var body: some View {
        HStack {
            ValidatorImageView(validator: delegation.delegation.validator)
            ListItemView(
                title: delegation.validatorText,
                titleExtra: delegation.stateText,
                titleStyleExtra: TextStyle(font: .footnote, color: delegation.stateTextColor),
                subtitle: delegation.balanceText,
                subtitleExtra: delegation.completionDateText,
                subtitleStyleExtra: .footnote
            )
        }
    }
}
