// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import SwiftUI
import Components
import PrimitivesComponents

struct ListAssetItemSelectionView: View {
    private let assetData: AssetData
    private let currencyCode: String
    private let type: AssetListType
    private let action: (ListAssetItemAction, AssetData) -> Void

    init(
        assetData: AssetData,
        currencyCode: String,
        type: AssetListType,
        action: @escaping (ListAssetItemAction, AssetData) -> Void
    ) {
        self.assetData = assetData
        self.currencyCode = currencyCode
        self.type = type
        self.action = action
    }

    var body: some View {
        ListAssetItemView(
            model: ListAssetItemViewModel(
                showBalancePrivacy: .constant(false),
                assetDataModel: AssetDataViewModel(
                    assetData: assetData,
                    formatter: .abbreviated,
                    currencyCode: currencyCode
                ),
                type: type,
                action: {
                    action($0, assetData)
                }
            )
        )
    }
}
