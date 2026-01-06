// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import Localization
import PrimitivesComponents
import AssetsService
import Perpetuals

public struct WalletSearchScene: View {
    @State private var model: WalletSearchSceneViewModel

    public init(model: WalletSearchSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        SearchableWrapper(
            content: { assetsList },
            isSearching: $model.isSearching,
            dismissSearch: $model.dismissSearch
        )
        .overlay {
            if model.showLoading {
                LoadingView()
            } else if model.showEmpty {
                EmptyContentView(
                    model: EmptyContentTypeViewModel(
                        type: .search(
                            type: .assets,
                            action: model.showAddToken ? { model.onSelectAddCustomToken() } : nil
                        )
                    )
                )
            }
        }
        .observeQuery(request: $model.request, value: $model.assets)
        .observeQuery(request: $model.recentActivityRequest, value: $model.recentActivities)
        .observeQuery(request: $model.positionsRequest, value: $model.positions)
        .searchable(
            text: $model.searchModel.searchableQuery,
            isPresented: $model.isSearchPresented,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .autocorrectionDisabled(true)
        .debounce(
            value: $model.searchModel.searchableQuery.wrappedValue,
            interval: Duration.milliseconds(250),
            action: model.onSearch(query:)
        )
        .onChange(of: model.searchModel.searchableQuery, model.onChangeSearchQuery)
        .onChange(of: model.isSearching, model.onChangeFocus)
        .onChange(of: model.isSearchPresented, model.onChangeSearchPresented)
        .onAppear {
            model.onAppear()
        }
        .toast(message: $model.isPresentingToastMessage)
    }

    @ViewBuilder
    private var assetsList: some View {
        List {
            if model.showTags {
                Section {} header: {
                    TagsView(
                        tags: model.searchModel.tagsViewModel.items,
                        onSelect: { model.onSelectTag(tag: $0.tag) }
                    )
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets())
            }

            if model.showRecent {
                RecentActivitySectionView(models: model.activityModels) { assetModel in
                    NavigationLink(value: Scenes.Asset(asset: assetModel.asset)) {
                        AssetChipView(model: assetModel)
                    }
                }
            }

            if model.showPerpetuals {
                Section {
                    PerpetualPositionsList(positions: model.positions)
                } header: {
                    HeaderNavigationLinkView(
                        title: Localized.Perpetuals.title,
                        destination: Scenes.Perpetuals()
                    )
                }
                .listRowInsets(.assetListRowInsets)
            }

            if model.showPinned {
                Section(
                    content: { list(for: model.sections.pinned) },
                    header: {
                        HStack {
                            model.pinnedImage
                            Text(model.pinnedTitle)
                        }
                    }
                )
                .listRowInsets(.assetListRowInsets)
            }

            if model.showAssets {
                Section(
                    content: { list(for: model.sections.assets) },
                    header: {
                        Text(model.assetsTitle)
                    }
                )
                .listRowInsets(.assetListRowInsets)
            }
        }
        .contentMargins([.top], .extraSmall, for: .scrollContent)
        .listSectionSpacing(.compact)
    }

    @ViewBuilder
    private func list(for items: [AssetData]) -> some View {
        ForEach(items) { assetData in
            NavigationCustomLink(
                with: ListAssetItemView(
                    model: ListAssetItemViewModel(
                        showBalancePrivacy: .constant(false),
                        assetData: assetData,
                        formatter: .abbreviated,
                        currencyCode: model.currencyCode
                    )
                )
                .contextMenu(model.contextMenuItems(for: assetData)),
                action: { model.onSelectAsset(assetData.asset) }
            )
        }
    }
}
