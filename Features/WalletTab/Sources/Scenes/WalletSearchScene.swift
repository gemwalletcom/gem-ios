// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import Localization
import PrimitivesComponents
import AssetsService

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
    }

    @ViewBuilder
    private var assetsList: some View {
        List {
            if model.showTags {
                Section {
                    TagsView(
                        tags: model.searchModel.tagsViewModel.items,
                        onSelect: { model.onSelectTag(tag: $0.tag) }
                    )
                }
                .cleanListRow(topOffset: .zero)
                .lineSpacing(.zero)
                .listSectionSpacing(.zero)
            }

            if model.showRecentSearches {
                Section {} header: {
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text(model.recentActivityTitle)
                            .padding(.leading, Spacing.space12)
                        recentActivitiesCollection
                    }
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets())
                .listSectionSpacing(.zero)
            }

            if model.showPinnedSection {
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

            if model.showAssetsSection {
                Section(
                    content: { list(for: model.sections.assets) },
                    header: {
                        Text(model.assetsTitle)
                    }
                )
                .listRowInsets(.assetListRowInsets)
            }
        }
        .contentMargins(.top, .zero, for: .scrollContent)
    }

    @ViewBuilder
    private var recentActivitiesCollection: some View {
        AssetsCollectionView(models: model.activityModels) { assetModel in
            NavigationLink(value: Scenes.Asset(asset: assetModel.asset)) {
                AssetChipView(model: assetModel)
            }
        }
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
                ),
                action: { model.onSelectAsset(assetData.asset) }
            )
        }
    }
}
