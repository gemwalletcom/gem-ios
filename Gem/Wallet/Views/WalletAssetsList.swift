// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct WalletAssetsList: View {
    
    let assets: [AssetData]
    let copyAssetAddress: StringAction
    let hideAsset: AssetIdAction
    
    var body: some View {
        ForEach(assets, id: \.self) { asset in
            NavigationLink(value: asset) {
                AssetListView.make(assetData: asset, formatter: .short)
                    .contextMenu {
                        ContextMenuItem(
                            title: Localized.Wallet.copyAddress,
                            image: SystemImage.copy
                        ) {
                            copyAssetAddress?(asset.account.address)
                        }
                        ContextMenuItem(
                            title: Localized.Common.hide,
                            image: SystemImage.hide
                        ) {
                            hideAsset?(asset.asset.id)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(Localized.Common.hide, role: .destructive) {
                            hideAsset?(asset.asset.id)
                        }
                        .tint(Colors.gray)
                    }
            }
        }
    }
}
