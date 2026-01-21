// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives

public struct YieldOpportunityView: View {
    private let model: YieldOpportunityViewModel
    private let displayName: String
    private let action: () -> Void

    public init(
        model: YieldOpportunityViewModel,
        displayName: String,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.displayName = displayName
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.medium) {
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
                    VStack(alignment: .trailing, spacing: Spacing.tiny) {
                        Text("APR")
                            .font(.caption)
                            .foregroundStyle(Colors.gray)

                        Text(model.apyText)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(Colors.green)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Colors.gray)
            }
            .padding(.vertical, Spacing.small)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
