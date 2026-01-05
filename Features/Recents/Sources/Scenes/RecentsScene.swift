// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Components
import Localization
import Style
import Store

public struct RecentsScene: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: RecentsSceneViewModel

    public init(model: RecentsSceneViewModel) {
        _model = State(wrappedValue: model)
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(model.sections) { section in
                    Section {
                        ForEach(section.assets) { recentAsset in
                            let assetModel = AssetViewModel(asset: recentAsset.asset)
                            NavigationCustomLink(
                                with: ListItemView(
                                    title: assetModel.name,
                                    imageStyle: .asset(assetImage: assetModel.assetImage)
                                )
                            ) {
                                model.onSelect(recentAsset.asset)
                            }
                        }
                        .listRowInsets(.assetListRowInsets)
                    } header: {
                        Text(section.title)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .contentMargins(.top, .scene.top, for: .scrollContent)
            .navigationTitle(Localized.RecentActivity.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
        .observeQuery(request: $model.request, value: $model.recentAssets)
    }
}
