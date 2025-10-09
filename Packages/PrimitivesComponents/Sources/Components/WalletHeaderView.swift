// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization
import Primitives

public struct WalletHeaderView: View {
    private let model: any HeaderViewModel

    @Binding var isHideBalanceEnalbed: Bool

    private let onHeaderAction: HeaderButtonAction?
    private let onInfoAction: VoidAction

    public init(
        model: any HeaderViewModel,
        isHideBalanceEnalbed: Binding<Bool>,
        onHeaderAction: HeaderButtonAction?,
        onInfoAction: VoidAction
    ) {
        self.model = model
        _isHideBalanceEnalbed = isHideBalanceEnalbed
        self.onHeaderAction = onHeaderAction
        self.onInfoAction = onInfoAction
    }

    public var body: some View {
        VStack(spacing: .large/2) {
            if let assetImage = model.assetImage {
                AssetImageView(
                    assetImage: assetImage,
                    size: 64
                )
            }
            ZStack {
                if model.allowHiddenBalance {
                    PrivacyToggleView(
                        model.title,
                        isEnabled: $isHideBalanceEnalbed
                    )
                } else {
                    Text(model.title)
                }
            }
            .numericTransition(for: model.title)
            .minimumScaleFactor(0.5)
            .font(.system(size: 42))
            .fontWeight(.semibold)
            .foregroundStyle(Colors.black)
            .lineLimit(1)

            if let subtitle = model.subtitle {
                PrivacyText(
                    subtitle,
                    isEnabled: isEnabled
                )
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundStyle(Colors.gray)
                .numericTransition(for: model.subtitle)
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
                    .padding(.top, .medium)
                }

            case false:
                HeaderButtonsView(buttons: model.buttons, action: onHeaderAction)
                    .padding(.top, .small)
            }
        }
    }

    private var isEnabled: Binding<Bool> {
        return model.allowHiddenBalance ? $isHideBalanceEnalbed : .constant(false)
    }
}

// MARK: - Previews

#Preview {
    let model = WalletHeaderViewModel(
        walletType: .multicoin,
        value: 1_000,
        currencyCode: Currency.usd.rawValue,
        bannerEventsViewModel: HeaderBannerEventViewModel(events: [])
    )

    WalletHeaderView(
        model: model,
        isHideBalanceEnalbed: .constant(false),
        onHeaderAction: .none,
        onInfoAction: .none
    )
}
