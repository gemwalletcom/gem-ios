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
                    } header: {
                        Text(section.title)
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.compact)
            .searchable(
                text: $model.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .autocorrectionDisabled()
            .overlay {
                if model.showEmpty {
                    EmptyContentView(model: model.emptyModel)
                }
            }
            .navigationTitle(Localized.RecentActivity.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarDismissItem(title: .cancel, placement: .topBarLeading) }
        }
        .observeQuery(request: $model.request, value: $model.recentAssets)
    }
}
