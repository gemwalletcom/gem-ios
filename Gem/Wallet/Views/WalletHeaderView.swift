// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization

struct WalletHeaderView: View {
    
    let model: any HeaderViewModel
    var action: HeaderButtonAction?
    
    var body: some View {
        VStack(spacing: Spacing.large/2) {
            if let assetImage = model.assetImage {
                AssetImageView(
                    assetImage: assetImage,
                    size: 64,
                    overlayImageSize: 26
                )
            }
            
            Text(model.title)
                .minimumScaleFactor(0.5)
                .font(.system(size: 42))
                .fontWeight(.semibold)
                .foregroundColor(Colors.black)
                .lineLimit(1)
                
            if let subtitle = model.subtitle {
                Text(subtitle)
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.gray)
            }
            
            switch model.isWatchWallet {
            case true:
                HStack {
                    Image(systemName: SystemImage.eye)
                    
                    Text(Localized.Wallet.Watch.Tooltip.title)
                        .foregroundColor(Colors.black)
                        .font(.callout)
                    
                    if let url = model.infoButtonUrl {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            Image(systemName: SystemImage.info)
                                .tint(Colors.black)
                        }
                    }
                }
                .padding()
                .background(Colors.grayDarkBackground)
                .cornerRadius(Spacing.medium)
                .padding(.top, Spacing.medium)
            case false:
                HeaderButtonsView(buttons: model.buttons, action: action)
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
    return WalletHeaderView(model: model, action: nil)
}
