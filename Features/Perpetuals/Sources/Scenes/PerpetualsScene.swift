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
        .listSectionSpacing(.compact)
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

            if model.showRecent {
                RecentActivitySectionView(models: model.activityModels, headerPadding: .medium + .tiny) { assetModel in
                    Button {
                        model.onSelectRecentPerpetual(asset: assetModel.asset)
                    } label: {
                        AssetChipView(model: assetModel)
                    }
                }
            }

            if model.showPositions {
                Section {
                    PerpetualPositionsList(
                        positions: model.positions,
                        onSelect: model.onSelectPerpetual
                    )
                } header: {
                    Text(model.positionsSectionTitle)
                }
                .listRowInsets(.assetListRowInsets)
            }

            if model.showPinned {
                Section {
                    PerpetualSectionView(
                        perpetuals: model.sections.pinned,
                        onPin: model.onPinPerpetual,
                        onSelect: model.onSelectPerpetual
                    )
                } header: {
                    HStack {
                        model.pinImage
                        Text(model.pinnedSectionTitle)
                    }
                }
            }

            if model.showMarkets {
                Section {
                    PerpetualSectionView(
                        perpetuals: model.sections.markets,
                        onPin: model.onPinPerpetual,
                        onSelect: model.onSelectPerpetual,
                        emptyText: model.noMarketsText
                    )
                } header: {
                    Text(model.marketsSectionTitle)
                }
            }
        }
        .contentMargins([.top], .space12, for: .scrollContent)
    }
}
