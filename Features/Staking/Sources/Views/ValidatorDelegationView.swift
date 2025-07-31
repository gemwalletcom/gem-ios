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
        ListItemView(
            title: delegation.validatorText,
            titleStyle: delegation.titleStyle,
            titleTag: delegation.stateText,
            titleTagStyle: delegation.stateTagStyle,
            titleExtra: delegation.completionDateText,
            titleStyleExtra: delegation.titleExtraStyle,
            subtitle: delegation.balanceText,
            subtitleStyle: delegation.subtitleStyle,
            subtitleExtra: delegation.fiatValueText,
            subtitleStyleExtra: delegation.subtitleExtraStyle,
            imageStyle: .asset(assetImage: delegation.validatorImage)
        )
    }
}
