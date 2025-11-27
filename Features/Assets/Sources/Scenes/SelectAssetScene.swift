import SwiftUI
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents

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
        .listSectionSpacing(.compact)
        .searchable(
            text: $model.searchModel.searchableQuery,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .if(model.isNetworkSearchEnabled) {
            $0.debounce(
                value: $model.searchModel.searchableQuery.wrappedValue,
                interval: Duration.milliseconds(250),
                action: model.search(query:)
            )
        }
        .overlay {
            if model.state.isLoading, model.sections.assets.isEmpty {
                LoadingView()
            } else if model.sections.assets.isEmpty {
                EmptyContentView (
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
        .onChange(of: model.filterModel, model.onChangeFilterModel)
        .onChange(of: model.searchModel.searchableQuery, model.updateRequest)
        .onChange(of: model.isSearching, model.onChangeFocus)
        .ifLet(model.copyTypeViewModel) {
            $0.copyToast(
                model: $1,
                isPresenting: $model.isPresentingCopyToast
            )
        }
        .listSectionSpacing(.compact)
        .navigationBarTitle(model.title)
    }

    var list: some View {
        List {
            Section {} header: {
                TagsView(
                    tags: model.searchModel.tagsViewModel.items,
                    onSelect: { model.setSelected(tag: $0.tag) }
                )
                .isVisible(model.showTags)
            }
            .textCase(nil)
            .listRowInsets(EdgeInsets())
            .if(model.showRecentActivities) {
                $0.listSectionSpacing(.small)
            }

            if model.showRecentActivities {
                Section(
                    content: { recentActivitiesCollection },
                    header: {
                        HStack {
                            Text(model.recentActivityTitle)
                                .padding(.leading, Spacing.space12)
                            Spacer()
                        }
                    }
                )
                .cleanListRow(topOffset: .zero)
            }

            if model.enablePopularSection && model.sections.popular.isNotEmpty {
                Section {
                    assetsList(assets: model.sections.popular)
                } header: {
                    HStack {
                        Images.System.starFill
                        Text(Localized.Common.popular)
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }

            if model.sections.pinned.isNotEmpty {
                Section {
                    assetsList(assets: model.sections.pinned)
                } header: {
                    HStack {
                        Images.System.pin
                        Text(Localized.Common.pinned)
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }

            Section {
                assetsList(assets: model.sections.assets)
            }
            .listRowInsets(.assetListRowInsets)
        }
        .contentMargins([.top], .extraSmall, for: .scrollContent)
    }

    @ViewBuilder
    private var recentActivitiesCollection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small) {
                ForEach(model.recentActivities) { asset in
                    let assetModel = AssetViewModel(asset: asset)
                    NavigationLink(value: SelectAssetInput(type: model.selectType, assetAddress: model.assetAddress(for: asset))) {
                        ListItemView(
                            title: assetModel.symbol,
                            titleStyle: TextStyle(font: .body, color: .primary, fontWeight: .semibold),
                            imageStyle: .list(assetImage: assetModel.assetImage, cornerRadiusType: .rounded)
                        )
                        .padding(Spacing.small)
                        .background(
                            Colors.listStyleColor,
                            in: RoundedRectangle(cornerRadius: .large)
                        )
                    }
                }
            }
        }
    }

    func assetsList(assets: [AssetData]) -> some View {
        ForEach(assets) { assetData in
            switch model.selectType {
            case .buy, .receive, .send, .deposit, .withdraw:
                NavigationLink(value: SelectAssetInput(type: model.selectType, assetAddress: assetData.assetAddress)) {
                    ListAssetItemSelectionView(
                        assetData: assetData,
                        currencyCode: model.currencyCode,
                        type: model.selectType.listType,
                        action: model.onAssetAction
                    )
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

