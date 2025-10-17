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
        ListItemFlexibleView(
            left: { AssetImageView(assetImage: delegation.validatorImage) },
            primary: { primaryContent },
            secondary: { secondaryContent }
        )
    }
}

extension ValidatorDelegationView {
    @ViewBuilder
    private var primaryContent: some View {
        VStack(alignment: .leading, spacing: Spacing.tiny) {
            Text(delegation.validatorText)
                .textStyle(delegation.titleStyle)
                .lineLimit(1)
            HStack(spacing: .tiny) {
                if let stateText = delegation.stateText {
                    Text(stateText)
                        .textStyle(delegation.stateStyle)
                }
                if let completionDateText = delegation.completionDateShortText {
                    Text(completionDateText)
                        .textStyle(delegation.subtitleExtraStyle)
                }
            }
            .lineLimit(1)
        }
    }

    @ViewBuilder
    private var secondaryContent: some View {
        ListItemView(
            subtitle: delegation.balanceText,
            subtitleStyle: delegation.subtitleStyle,
            subtitleExtra: delegation.fiatValueText,
            subtitleStyleExtra: delegation.subtitleExtraStyle,
        )
    }
}
