// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Style
import Components
import GemstonePrimitives

protocol HeaderViewModel {
    var isWatchWallet: Bool { get }
    var assetImage: AssetImage? { get }
    var title: String { get }
    var subtitle: String? { get }
    var buttons: [HeaderButton] { get }
}

struct WalletHeaderView: View {
    @Environment(\.deviceLayoutState) var layoutState

    let model: HeaderViewModel
    var action: HeaderButtonAction?

    var body: some View {
        VStack(spacing: Spacing.large / 2) {
            if let assetImage = model.assetImage {
                AssetImageView(
                    assetImage: assetImage,
                    size: 64,
                    overlayImageSize: 26
                )
            }

            Text(model.title)
                .textStyle(
                    TextStyle(
                        font: .system(size: 42, weight: .semibold),
                        color: Colors.black
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if let subtitle = model.subtitle {
                Text(subtitle)
                    .textStyle(
                        TextStyle(
                            font: .system(size: 18, weight: .semibold),
                            color: Colors.gray
                        )
                    )
            }

            switch model.isWatchWallet {
            case true:
                HStack {
                    Image(systemName: SystemImage.eye)

                    Text(Localized.Wallet.Watch.Tooltip.title)
                        .foregroundColor(Colors.black)
                        .font(.callout)

                    Button {
                        UIApplication.shared.open(Docs.url(.whatIsWatchWallet))
                    } label: {
                        Image(systemName: SystemImage.info)
                            .tint(Colors.black)
                    }
                }
                .padding()
                .background(Colors.grayDarkBackground)
                .cornerRadius(Spacing.medium)
                .padding(.top, Spacing.medium)
            case false:
                HStack {
                    Spacer()
                    HeaderButtonsView(buttons: model.buttons, action: action, screenWidth: layoutState.layout.size.width)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let model = AssetHeaderViewModel(assetDataModel: .init(assetData: .main, formatter: .full_US),
                                     walletModel: .init(wallet: .main))

    return List {
        WalletHeaderView(model: model, action: nil)
    }
}
