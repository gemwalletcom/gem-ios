// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Components
import Style
import Store

public struct RecentsScene: View {
    @State private var model: RecentsSceneViewModel

    public init(model: RecentsSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(model.sections) { section in
                    Section {
                        ForEach(section.values) { recentAsset in
                            let assetModel = AssetViewModel(asset: recentAsset.asset)
                            NavigationCustomLink(
                                with: ListItemView(
                                    title: assetModel.name,
                                    titleStyle: TextStyle(font: .body, color: .primary, fontWeight: .semibold),
                                    imageStyle: .asset(assetImage: assetModel.assetImage)
                                )
                            ) {
                                model.onSelect(recentAsset.asset)
                            }
                        }
                    } header: {
                        section.title.map { Text($0) }
                            .fontWeight(.semibold)
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.compact)
            .scrollContentBackground(.hidden)
            .background { Colors.sheetInsetGroupedListStyle.ignoresSafeArea() }
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
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarContent {
                ToolbarDismissItem(type: .close, placement: .topBarLeading)
                if model.showClear {
                    ToolbarItemView(placement: .topBarTrailing) {
                        Button(model.clearTitle, action: model.onSelectClear)
                            .bold()
                    }
                }
            }
        }
        .bindQuery(model.query)
    }
}

