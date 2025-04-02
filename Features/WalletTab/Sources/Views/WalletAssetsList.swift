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

    let onCopyAssetAddress: StringAction
    let onHideAsset: AssetIdAction
    let onPinAsset: AssetIdBoolAction

    @Binding var showBalancePrivacy: Bool

    init(
        assets: [AssetData],
        currencyCode: String,
        onCopyAssetAddress: StringAction,
        onHideAsset: AssetIdAction,
        onPinAsset: AssetIdBoolAction,
        showBalancePrivacy: Binding<Bool>
    ) {
        self.assets = assets
        self.onCopyAssetAddress = onCopyAssetAddress
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
                .contextMenu {
                    ContextMenuItem(
                        title: Localized.Wallet.copyAddress,
                        image: SystemImage.copy
                    ) {
                        onCopyAssetAddress?(asset.account.address)
                    }
                    ContextMenuPin(
                        isPinned: asset.metadata.isPinned
                    ) {
                        onPinAsset?(asset.asset.id, !asset.metadata.isPinned)
                    }
                    ContextMenuItem(
                        title: Localized.Common.hide,
                        image: SystemImage.hide
                    ) {
                        onHideAsset?(asset.asset.id)
                    }
                }
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
