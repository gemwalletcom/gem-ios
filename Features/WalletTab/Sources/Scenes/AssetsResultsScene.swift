// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import PrimitivesComponents

public struct AssetsResultsScene: View {
    @Environment(\.dismiss) private var dismiss
    @State private var model: AssetsResultsSceneViewModel

    public init(model: AssetsResultsSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            List {
                if model.showPinned {
                    Section(
                        content: { assetItems(for: model.sections.pinned) },
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
            .toolbar {
                ToolbarDismissItem(title: .done, placement: .cancellationAction)
            }
        }
        .observeQuery(request: $model.request, value: $model.searchResult)
        .toast(message: $model.isPresentingToastMessage)
    }

    @ViewBuilder
    private func assetItems(for items: [AssetData]) -> some View {
        AssetItemsView(
            items: items,
            currencyCode: model.currencyCode,
            contextMenuItems: model.contextMenuItems,
            onSelect: {
                dismiss()
                model.onSelectAssetAction?($0)
            }
        )
    }
}
