import SwiftUI
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents

public struct SelectAssetScene: View {

    @State private var isPresentingCopyToast: Bool = false
    @State private var copyTypeViewModel: CopyTypeViewModel?

    @Binding private var isPresentingAddToken: Bool

    @State private var model: SelectAssetViewModel

    public init(
        model: SelectAssetViewModel,
        isPresentingAddToken: Binding<Bool>
    ) {
        _model = State(wrappedValue: model)
        _isPresentingAddToken = isPresentingAddToken
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
                            action: model.showAddToken ? { onSelectAddCustomToken() } : nil
                        )
                    )
                )
            }
        }
        .observeQuery(request: $model.request, value: $model.assets)
        .onChange(of: model.filterModel, model.onChangeFilterModel)
        .onChange(of: model.searchModel.searchableQuery, model.updateRequest)
        .onChange(of: model.isSearching, model.onChangeFocus)
        .ifLet(copyTypeViewModel) {
            $0.copyToast(
                model: $1,
                isPresenting: $isPresentingCopyToast
            )
        }
        .listSectionSpacing(.compact)
        .navigationBarTitle(model.title)
    }

    var list: some View {
        List {
            Section {} header: {
                TagsView(model: model.searchModel.tagsViewModel) {
                    model.setSelected(tag: $0)
                }
                .isVisible(model.shouldShowTagFilter)
            }
            .textCase(nil)
            .listRowInsets(EdgeInsets())

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
    }

    func assetsList(assets: [AssetData]) -> some View {
        ForEach(assets) { assetData in
            switch model.selectType {
            case .buy, .receive, .send:
                NavigationLink(value: SelectAssetInput(type: model.selectType, assetAddress: assetData.assetAddress)) {
                    ListAssetItemSelectionView(
                        assetData: assetData,
                        currencyCode: model.currencyCode,
                        type: model.selectType.listType,
                        action: onAsset
                    )
                }
            case .manage:
                ListAssetItemSelectionView(
                    assetData: assetData,
                    currencyCode: model.currencyCode,
                    type: model.selectType.listType,
                    action: onAsset
                )
            case .swap, .priceAlert:
                NavigationCustomLink(
                    with: ListAssetItemSelectionView(
                        assetData: assetData,
                        currencyCode: model.currencyCode,
                        type: model.selectType.listType,
                        action: onAsset
                    )
                ) {
                    model.selectAsset(asset: assetData.asset)
                }
            }
        }
    }
}

// MARK: - Actions

extension SelectAssetScene {
    private func onSelectAddCustomToken() {
        isPresentingAddToken.toggle()
    }

    private func onAsset(action: ListAssetItemAction, assetData: AssetData) {
        let asset = assetData.asset
        switch action {
        case .switcher(let enabled):
            Task {
                await model.handleAction(assetId: asset.id, enabled: enabled)
            }
        case .copy:
            let address = assetData.account.address
            copyTypeViewModel = CopyTypeViewModel(
                type: .address(asset, address: address),
                copyValue: address
            )
            isPresentingCopyToast = true
            Task {
                await model.handleAction(assetId: asset.id, enabled: true)
            }
        }
    }
}
