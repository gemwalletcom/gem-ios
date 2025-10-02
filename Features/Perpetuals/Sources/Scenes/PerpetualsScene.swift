// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Store
import PerpetualService
import PrimitivesComponents
import Preferences

public struct PerpetualsScene: View {
    @Bindable private var model: PerpetualsSceneViewModel

    public init(model: PerpetualsSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        SearchableWrapper(
            content: { list },
            isSearching: $model.isSearching,
            dismissSearch: .constant(false)
        )
        .searchable(
            text: $model.searchQuery,
            isPresented: $model.isSearchPresented,
            placement: .navigationBarDrawer(displayMode: .automatic)
        )
        .onChange(of: model.searchQuery, model.onSearchQueryChange)
        .onChange(of: model.isSearchPresented, model.onSearchPresentedChange)
        .navigationTitle(model.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: model.onSelectSearchButton) {
                    model.searchImage
                }
            }
        }
        .taskOnce {
            Task {
                await model.fetch()
            }
        }
        .refreshable {
            await model.fetch()
        }
    }

    var list: some View {
        List {
            if !model.isSearching {
                Section { } header: {
                    WalletHeaderView(
                        model: model.headerViewModel,
                        isHideBalanceEnalbed: .constant(model.preferences.isHideBalanceEnabled),
                        onHeaderAction: model.onSelectHeaderAction,
                        onInfoAction: .none
                    )
                    .padding(.top, Spacing.small)
                }
                .cleanListRow()
            }

            if model.showPositions {
                Section {
                    ForEach(model.positions) { position in
                        NavigationLink(
                            value: Scenes.Perpetual(position.perpetualData),
                            label: {
                                ListAssetItemView(
                                    model: PerpetualPositionItemViewModel(model: PerpetualPositionViewModel(position))
                                )
                            }
                        )
                        .listRowInsets(.assetListRowInsets)
                    }
                } header: {
                    Text(model.positionsSectionTitle)
                }
            }

            if model.showPinned {
                Section {
                    PerpetualSectionView(
                        perpetuals: model.sections.pinned,
                        onPin: model.onPinPerpetual
                    )
                } header: {
                    HStack {
                        model.pinImage
                        Text(model.pinnedSectionTitle)
                    }
                }
            }
            Section {
                PerpetualSectionView(
                    perpetuals: model.sections.markets,
                    onPin: model.onPinPerpetual,
                    emptyText: model.noMarketsText
                )
            } header: {
                Text(model.marketsSectionTitle)
            }
        }
    }
}
