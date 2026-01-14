// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import PrimitivesComponents

struct AssetItemsView: View {
    let items: [AssetData]
    let currencyCode: String
    let contextMenuItems: (AssetData) -> [ContextMenuItemType]
    let onSelect: (Asset) -> Void

    var body: some View {
        ForEach(items) { assetData in
            NavigationCustomLink(
                with: ListAssetItemView(
                    model: ListAssetItemViewModel(
                        showBalancePrivacy: .constant(false),
                        assetData: assetData,
                        formatter: .abbreviated,
                        currencyCode: currencyCode
                    )
                )
                .contextMenu(contextMenuItems(assetData)),
                action: { onSelect(assetData.asset) }
            )
        }
    }
}
