// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization
import InfoSheet
import Primitives

struct WalletHeaderView: View {
    @Environment(\.observablePreferences) var observablePreferences

    let model: any HeaderViewModel
    var onInfoSheetAction: ((InfoSheetType) -> Void)?
    var onHeaderAction: HeaderButtonAction?

    var body: some View {
        @Bindable var preferences = observablePreferences
        VStack(spacing: Spacing.large/2) {
            if let assetImage = model.assetImage {
                AssetImageView(
                    assetImage: assetImage,
                    size: 64,
                    overlayImageSize: 26
                )
            }
            ZStack {
                if model.showBalancePrivacy {
                    PrivacyToggleView(
                        model.title,
                        isEnabled: $preferences.isBalancePrivacyEnabled
                    )
                } else {
                    Text(model.title)
                }
            }
            .minimumScaleFactor(0.5)
            .font(.system(size: 42))
            .fontWeight(.semibold)
            .foregroundStyle(Colors.black)
            .lineLimit(1)

            if let subtitle = model.subtitle {
                PrivacyText(
                    subtitle,
                    balancePrivacyEnabled: model.showBalancePrivacy ? $preferences.isBalancePrivacyEnabled : .constant(false)
                )
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundStyle(Colors.gray)
            }

            switch model.isWatchWallet {
            case true:
                Button {
                    onInfoSheetAction?(.watchWallet)
                } label: {
                    HStack {
                        Image(systemName: SystemImage.eye)

                        Text(Localized.Wallet.Watch.Tooltip.title)
                            .foregroundColor(Colors.black)
                            .font(.callout)

                        Image(systemName: SystemImage.info)
                            .tint(Colors.black)
                    }
                    .padding()
                    .background(Colors.grayDarkBackground)
                    .cornerRadius(Spacing.medium)
                    .padding(.top, Spacing.medium)
                }

            case false:
                HeaderButtonsView(buttons: model.buttons, action: onHeaderAction)
                    .padding(.top, Spacing.small)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let model = AssetHeaderViewModel(
        assetDataModel: .init(assetData: .main, formatter: .full_US),
        walletModel: .init(wallet: .main),
        bannersViewModel: HeaderBannersViewModel(banners: [])
    )
    return WalletHeaderView(model: model, onInfoSheetAction: .none, onHeaderAction: .none)
}
