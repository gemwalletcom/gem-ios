// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import PrimitivesComponents

public struct AssetsResultsScene: View {
    @State private var model: AssetsResultsSceneViewModel

    public init(model: AssetsResultsSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            if model.showPinned {
                Section(
                    content: { assetItems(for: model.sections.pinnedAssets) },
                    header: { PinnedSectionHeader() }
                )
                .listRowInsets(.assetListRowInsets)
            }

            if model.showAssets {
                Section {
                    assetItems(for: model.sections.assets)
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .observeQuery(request: $model.request, value: $model.searchResult)
        .toast(message: $model.isPresentingToastMessage)
    }

    @ViewBuilder
    private func assetItems(for items: [AssetData]) -> some View {
        AssetItemsView(
            items: items,
            currencyCode: model.currencyCode,
            contextMenuItems: model.contextMenuItems,
            onSelect: { model.onSelectAssetAction?($0) }
        )
    }
}
