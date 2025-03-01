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
    let copyAssetAddress: StringAction
    let hideAsset: AssetIdAction
    let pinAsset: AssetIdBoolAction
    let currencyCode: String

    @Binding var showBalancePrivacy: Bool

    init(
        assets: [AssetData],
        copyAssetAddress: StringAction,
        hideAsset: @escaping AssetIdAction,
        pinAsset: AssetIdBoolAction,
        currencyCode: String,
        showBalancePrivacy: Binding<Bool>
    ) {
        self.assets = assets
        self.copyAssetAddress = copyAssetAddress
        self.hideAsset = hideAsset
        self.pinAsset = pinAsset
        self.currencyCode = currencyCode
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
                        copyAssetAddress?(asset.account.address)
                    }
                    ContextMenuPin(
                        isPinned: asset.metadata.isPinned
                    ) {
                        pinAsset?(asset.asset.id, !asset.metadata.isPinned)
                    }
                    ContextMenuItem(
                        title: Localized.Common.hide,
                        image: SystemImage.hide
                    ) {
                        hideAsset(asset.asset.id)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(Localized.Common.hide, role: .destructive) {
                        hideAsset(asset.asset.id)
                    }
                    .tint(Colors.gray)
                }
            }
        }
    }
}
