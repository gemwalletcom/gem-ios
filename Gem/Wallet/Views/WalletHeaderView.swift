// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization
import InfoSheet
import Primitives

struct WalletHeaderView: View {
    let model: any HeaderViewModel

    @Binding var isBalancePrivacyEnabled: Bool

    var onHeaderAction: HeaderButtonAction?
    var onInfoSheetAction: ((InfoSheetType) -> Void)?

    var body: some View {
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
                        isEnabled: $isBalancePrivacyEnabled
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
                    isEnabled: isEnabled
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
                        Images.System.eye

                        Text(Localized.Wallet.Watch.Tooltip.title)
                            .foregroundColor(Colors.black)
                            .font(.callout)

                        Images.System.info
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

    private var isEnabled: Binding<Bool> {
        return model.showBalancePrivacy ? $isBalancePrivacyEnabled : .constant(false)
    }
}

// MARK: - Previews

#Preview {
    let model = AssetHeaderViewModel(
        assetDataModel: .init(assetData: .main, formatter: .full_US),
        walletModel: .init(wallet: .main),
        bannersViewModel: HeaderBannersViewModel(banners: [])
    )

    WalletHeaderView(
        model: model,
        isBalancePrivacyEnabled: .constant(false),
        onHeaderAction: .none,
        onInfoSheetAction: .none
    )
}
