// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives

public struct EarnProviderView: View {
    private let model: EarnProviderViewModel
    private let displayName: String
    private let action: () -> Void

    public init(
        model: EarnProviderViewModel,
        displayName: String,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.displayName = displayName
        self.action = action
    }

    public var body: some View {
        NavigationCustomLink(
            with: HStack(spacing: Spacing.medium) {
                model.providerImage

                VStack(alignment: .leading, spacing: Spacing.tiny) {
                    Text(displayName)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(Colors.black)

                    Text(model.providerName)
                        .font(.callout)
                        .foregroundStyle(Colors.gray)
                }

                Spacer()

                if model.hasApy {
                    Text(model.apyText)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(Colors.green)
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, Spacing.extraSmall)
                        .background(Colors.green.opacity(0.1))
                        .cornerRadius(Spacing.small)
                }
            }
            .padding(.vertical, Spacing.small),
            action: action
        )
    }
}
