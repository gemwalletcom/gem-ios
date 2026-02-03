// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization
import Primitives

public struct WalletHeaderView: View {
    private let model: any HeaderViewModel

    @Binding var isPrivacyEnabled: Bool

    private let balanceActionType: BalanceActionType
    private let onHeaderAction: HeaderButtonAction?
    private let onInfoAction: VoidAction

    public init(
        model: any HeaderViewModel,
        isPrivacyEnabled: Binding<Bool>,
        balanceActionType: BalanceActionType,
        onHeaderAction: HeaderButtonAction?,
        onInfoAction: VoidAction
    ) {
        self.model = model
        _isPrivacyEnabled = isPrivacyEnabled
        self.balanceActionType = balanceActionType
        self.onHeaderAction = onHeaderAction
        self.onInfoAction = onInfoAction
    }

    public var body: some View {
        VStack(spacing: .zero) {
            if let assetImage = model.assetImage {
                AssetImageView(
                    assetImage: assetImage,
                    size: .image.semiLarge
                )
                .padding(.bottom, .space12)
            }
            balanceView
            .numericTransition(for: model.title)
            .minimumScaleFactor(0.5)
            .font(.system(size: 42))
            .fontWeight(.semibold)
            .foregroundStyle(Colors.black)
            .lineLimit(1)
            .padding(.bottom, .space10)

            if let subtitle = model.subtitle {
                HStack(spacing: Spacing.small) {
                    PrivacyText(
                        subtitle,
                        isEnabled: $isPrivacyEnabled
                    )
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(model.subtitleColor)

                    if let badge = model.subtitleBadge, !isPrivacyEnabled {
                        Text(badge)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Colors.whiteSolid)
                            .padding(.horizontal, Spacing.small)
                            .padding(.vertical, Spacing.extraSmall)
                            .background(model.subtitleColor)
                            .clipShape(Capsule())
                    }
                }
                .numericTransition(for: model.subtitle)
                .padding(.bottom, .space10)
            }

            switch model.isWatchWallet {
            case true:
                Button {
                    onInfoAction?()
                } label: {
                    HStack {
                        Images.System.eye

                        Text(Localized.Wallet.Watch.Tooltip.title)
                            .foregroundColor(Colors.black)
                            .font(.callout)

                        Images.System.info
                            .tint(Colors.black)
                    }
                    .padding()
                    .background(Colors.grayDarkBackground)
                    .cornerRadius(.medium)
                    .padding(.top, .space10)
                }

            case false:
                HeaderButtonsView(buttons: model.buttons, action: onHeaderAction)
                    .padding(.top, .space8)
            }
        }
    }

    @ViewBuilder
    private var balanceView: some View {
        switch balanceActionType {
        case .privacyToggle:
            PrivacyToggleView(model.title, isEnabled: $isPrivacyEnabled)
        case .action(let action):
            Button(action: action) {
                PrivacyText(model.title, isEnabled: $isPrivacyEnabled)
            }
        case .none:
            Text(model.title)
        }
    }
}

// MARK: - Previews

#Preview {
    let model = WalletHeaderViewModel(
        walletType: .multicoin,
        totalValue: TotalFiatValue(value: 1_000, pnlAmount: 50, pnlPercentage: 5.26),
        currencyCode: Currency.usd.rawValue,
        bannerEventsViewModel: HeaderBannerEventViewModel(events: [])
    )

    WalletHeaderView(
        model: model,
        isPrivacyEnabled: .constant(false),
        balanceActionType: .privacyToggle,
        onHeaderAction: .none,
        onInfoAction: .none
    )
}
