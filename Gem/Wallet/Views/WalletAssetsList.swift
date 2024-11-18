// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style
import Localization

struct WalletAssetsList: View {
    @Environment(\.observablePreferences) var observablePreferences

    let assets: [AssetData]
    let copyAssetAddress: StringAction
    let hideAsset: AssetIdAction
    let pinAsset: AssetIdBoolAction

    init(
        assets: [AssetData],
        copyAssetAddress: StringAction,
        hideAsset: @escaping AssetIdAction,
        pinAsset: AssetIdBoolAction
    ) {
        self.assets = assets
        self.copyAssetAddress = copyAssetAddress
        self.hideAsset = hideAsset
        self.pinAsset = pinAsset
    }

    var body: some View {
        @Bindable var preferences = observablePreferences
        ForEach(assets) { asset in
            NavigationLink(value: Scenes.Asset(asset: asset.asset)) {
                ListAssetItemView(
                    model: ListAssetItemViewModel(
                        showBalancePrivacy: $preferences.isBalancePrivacyEnabled,
                        assetData: asset,
                        formatter: .short
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
