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
                    Button(Localized.Common.hide, role: .destructive) {
                        onHideAsset?(asset.asset.id)
                    }
                    .tint(Colors.gray)
                }
            }
        }
    }
}
