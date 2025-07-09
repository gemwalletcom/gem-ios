// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents

struct WalletAssetsList: View {
    let assets: [AssetData]
    let currencyCode: String
    let onHideAsset: AssetIdAction
    let onPinAsset: AssetIdBoolAction

    @Binding var showBalancePrivacy: Bool

    init(
        assets: [AssetData],
        currencyCode: String,
        onHideAsset: AssetIdAction,
        onPinAsset: AssetIdBoolAction,
        showBalancePrivacy: Binding<Bool>
    ) {
        self.assets = assets
        self.currencyCode = currencyCode
        self.onHideAsset = onHideAsset
        self.onPinAsset = onPinAsset
        _showBalancePrivacy = showBalancePrivacy
    }

    var body: some View {
        ForEach(assets) { asset in
            NavigationLink(value: Scenes.Asset(asset: asset.asset)) {
                ListAssetItemView(
                    model: ListAssetItemViewModel(
                        showBalancePrivacy: $showBalancePrivacy,
                        assetData: asset,
                        formatter: .short,
                        currencyCode: currencyCode
                    )
                )
                .contextMenu(
                    [
                        .copy(
                            title: Localized.Wallet.copyAddress,
                            value: asset.account.address
                        ),
                        .pin(
                            isPinned: asset.metadata.isPinned,
                            onPin: {
                                onPinAsset?(asset.asset.id, !asset.metadata.isPinned)
                            }
                        ),
                        .hide({ onHideAsset?(asset.asset.id) })
                    ]
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onHideAsset?(asset.asset.id)
                    } label: {
                        Label(
                            Localized.Common.hide,
                            systemImage: SystemImage.hide
                        )
                    }
                    .tint(Colors.red)
                }
                .swipeActions(edge: .leading) {
                    Button(role: .destructive) {
                        onPinAsset?(asset.asset.id, !asset.metadata.isPinned)
                    } label: {
                        Label(
                            asset.metadata.isPinned ? Localized.Common.unpin : Localized.Common.pin,
                            systemImage: asset.metadata.isPinned ? SystemImage.unpin : SystemImage.pin
                        )
                    }
                    .tint(Colors.green)
                }
            }
        }
    }
}
