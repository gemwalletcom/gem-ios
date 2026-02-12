import SwiftUI
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents
import Recents

public struct SelectAssetScene: View {

    @State private var model: SelectAssetViewModel

    public init(
        model: SelectAssetViewModel
    ) {
        _model = State(wrappedValue: model)
    }

    public var body: some View {
        SearchableWrapper(
            content: { list },
            isSearching: $model.isSearching,
            dismissSearch: $model.isDismissSearch
        )
        .searchable(
            text: $model.searchModel.searchableQuery,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .if(model.isNetworkSearchEnabled) {
            $0.debounce(
                value: $model.searchModel.searchableQuery.wrappedValue,
                interval: .Debounce.normal,
                action: model.search(query:)
            )
        }
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
        .observeQuery(request: $model.recentsRequest, value: $model.recents)
        .onChange(of: model.filterModel, model.onChangeFilterModel)
        .onChange(of: model.searchModel.searchableQuery, model.updateRequest)
        .onChange(of: model.isSearching, model.onChangeFocus)
        .ifLet(model.copyTypeViewModel) {
            $0.copyToast(
                model: $1,
                isPresenting: $model.isPresentingCopyToast
            )
        }
        .navigationBarTitle(model.title)
    }

    var list: some View {
        List {
            if model.showTags {
                Section {} header: {
                    TagsView(
                        tags: model.searchModel.tagsViewModel.items,
                        onSelect: { model.setSelected(tag: $0.tag) }
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
                    switch model.selectType {
                    case .send, .receive, .buy:
                        Button {
                            model.onSelectRecent(assetModel.asset)
                        } label: {
                            AssetChipView(model: assetModel)
                        }
                    case .swap:
                        Button {
                            model.selectAsset(asset: assetModel.asset)
                        } label: {
                            AssetChipView(model: assetModel)
                        }
                    case .manage, .priceAlert, .deposit, .withdraw:
                        EmptyView()
                    }
                }
            }

            if model.showPopularSection {
                Section {
                    assetsList(assets: model.sections.popular)
                } header: {
                    HStack {
                        model.popularImage
                        Text(model.popularTitle)
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }

            if model.showPinnedSection {
                Section {
                    assetsList(assets: model.sections.pinned)
                } header: {
                    PinnedSectionHeader()
                }
                .listRowInsets(.assetListRowInsets)
            }

            if model.showAssetsSection {
                Section {
                    assetsList(assets: model.sections.assets)
                } header: {
                    Text(model.assetsTitle)
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
        .contentMargins([.top], .extraSmall, for: .scrollContent)
        .listSectionSpacing(.compact)
    }

    func assetsList(assets: [AssetData]) -> some View {
        ForEach(assets) { assetData in
            switch model.selectType {
            case .buy, .receive, .send, .deposit, .withdraw:
                NavigationCustomLink(
                    with: ListAssetItemSelectionView(
                        assetData: assetData,
                        currencyCode: model.currencyCode,
                        type: model.selectType.listType,
                        action: model.onAssetAction
                    )
                ) {
                    model.onSelectAsset(assetData)
                }
            case .manage:
                ListAssetItemSelectionView(
                    assetData: assetData,
                    currencyCode: model.currencyCode,
                    type: model.selectType.listType,
                    action: model.onAssetAction
                )
            case .swap, .priceAlert:
                NavigationCustomLink(
                    with: ListAssetItemSelectionView(
                        assetData: assetData,
                        currencyCode: model.currencyCode,
                        type: model.selectType.listType,
                        action: model.onAssetAction
                    )
                ) {
                    model.selectAsset(asset: assetData.asset)
                }
            }
        }
    }
}

