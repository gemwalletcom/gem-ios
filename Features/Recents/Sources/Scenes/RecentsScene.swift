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
                            .fontWeight(.semibold)
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.compact)
            .scrollContentBackground(.hidden)
            .background { Colors.insetGroupedListStyle.ignoresSafeArea() }
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
            .toolbar {
                ToolbarDismissItem(title: .cancel, placement: .topBarLeading)
                if model.showClear {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(model.clearTitle) {
                            model.onSelectClear()
                        }
                        .bold()
                    }
                }
            }
            .alert(
                model.clearConfirmationTitle,
                presenting: $model.isPresentingClearConfirmation,
                sensoryFeedback: .warning
            ) { _ in
                Button(model.clearTitle, role: .destructive, action: onSelectConfirm)
            }
        }
        .observeQuery(request: $model.request, value: $model.recentAssets)
    }
}

// MARK: - Private

extension RecentsScene {
    private func onSelectConfirm() {
        model.onSelectConfirmClear()
    }
}
