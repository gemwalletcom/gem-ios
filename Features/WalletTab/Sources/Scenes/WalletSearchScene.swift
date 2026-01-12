// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import Localization
import PrimitivesComponents
import AssetsService
import Recents
import Perpetuals

public struct WalletSearchScene: View {
    @State private var model: WalletSearchSceneViewModel

    public init(model: WalletSearchSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        SearchableWrapper(
            content: { content },
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
        .observeQuery(request: $model.searchRequest, value: $model.searchResult)
        .observeQuery(request: $model.recentsRequest, value: $model.recents)
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
        .sheet(isPresented: $model.isPresentingRecents) {
            RecentsScene(model: model.recentsModel)
        }
        .sheet(isPresented: $model.isPresentingAssetsResults) {
            AssetsResultsScene(model: model.assetsResultsModel)
        }
    }

    @ViewBuilder
    private var content: some View {
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

            if model.showRecents {
                RecentActivitySectionView(
                    models: model.recentModels,
                    onSelectRecents: model.onSelectRecents
                ) { assetModel in
                    NavigationLink(value: Scenes.Asset(asset: assetModel.asset)) {
                        AssetChipView(model: assetModel)
                    }
                }
            }

            if model.showPinned {
                Section(
                    content: { assetItems(for: model.sections.pinned) },
                    header: { PinnedSectionHeader() }
                )
                .listRowInsets(.assetListRowInsets)
            }

            if model.showAssets {
                Section(
                    content: { assetItems(for: model.previewAssets) },
                    header: {
                        SectionHeaderView(
                            title: model.assetsTitle,
                            actionTitle: model.hasMore(for: .asset) ? Localized.Wallet.more : nil,
                            action: model.onSelectSeeAllAssets
                        )
                    }
                )
                .listRowInsets(.assetListRowInsets)
            }

            if model.showPerpetuals {
                Section(
                    content: { perpetualItems },
                    header: {
                        HeaderNavigationLinkView(title: model.perpetualsTitle, destination: Scenes.Perpetuals())
                    }
                )
                .listRowInsets(.assetListRowInsets)
            }
        }
        .contentMargins([.top], .extraSmall, for: .scrollContent)
        .listSectionSpacing(.compact)
    }

    @ViewBuilder
    private func assetItems(for items: [AssetData]) -> some View {
        AssetItemsView(
            items: items,
            currencyCode: model.currencyCode,
            contextMenuItems: model.contextMenuItems,
            onSelect: model.onSelectAsset
        )
    }

    @ViewBuilder
    private var perpetualItems: some View {
        ForEach(model.previewPerpetuals, id: \.perpetual.id) { perpetualData in
            NavigationLink(value: Scenes.Perpetual(perpetualData)) {
                ListAssetItemView(
                    model: PerpetualItemViewModel(
                        model: PerpetualViewModel(perpetual: perpetualData.perpetual)
                    )
                )
            }
        }
    }
}
