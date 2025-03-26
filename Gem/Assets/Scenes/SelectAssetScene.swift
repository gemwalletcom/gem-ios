import SwiftUI
import Primitives
import Components
import Store
import GRDBQuery
import Style
import Localization
import PrimitivesComponents

struct SelectAssetScene: View {

    @State private var isPresentingCopyToast: Bool = false
    @State private var copyTypeViewModel: CopyTypeViewModel?

    @Binding private var isPresentingAddToken: Bool

    @Query<AssetsRequest>
    private var assets: [AssetData]

    @State private var model: SelectAssetViewModel
    
    private var sections: AssetsSections {
        AssetsSections.from(assets)
    }

    init(
        model: SelectAssetViewModel,
        isPresentingAddToken: Binding<Bool>
    ) {
        _model = State(wrappedValue: model)
        _isPresentingAddToken = isPresentingAddToken

        let request = Binding {
            model.request
        } set: { new in
            model.request = new
        }
        _assets = Query(request)
    }

    var body: some View {
        SearchableWrapper(
            content: { list },
            onChangeIsSearching: model.onChangeFocus,
            onDismissSearch: model.setDismissSearchAction
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
            if model.state.isLoading, sections.assets.isEmpty {
                LoadingView()
            } else if sections.assets.isEmpty {
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
        .onChange(of: model.filterModel.chainsFilter.selectedChains, onChangeChains)
        .onChange(of: model.searchModel.searchableQuery, model.updateRequest)
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

            if model.enablePopularSection && !sections.popular.isEmpty {
                Section {
                    assetsList(assets: sections.popular)
                } header: {
                    HStack {
                        Images.System.starFill
                        Text(Localized.Common.popular)
                    }
                }
            }
            
            if !sections.pinned.isEmpty {
                Section {
                    assetsList(assets: sections.pinned)
                } header: {
                    HStack {
                        Images.System.pin
                        Text(Localized.Common.pinned)
                    }
                }
            }
            
            Section {
                assetsList(assets: sections.assets)
            }
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

    private func onChangeChains(_ _: [Chain], _ chains: [Chain]) {
        model.update(filterRequest: .chains(chains.map({ $0.rawValue })))
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

private struct ListAssetItemSelectionView: View {
    let assetData: AssetData
    let currencyCode: String
    let type: AssetListType
    let action: (ListAssetItemAction, AssetData) -> Void

    var body: some View {
        ListAssetItemView(
            model: ListAssetItemViewModel(
                showBalancePrivacy: .constant(false),
                assetDataModel: AssetDataViewModel(
                    assetData: assetData,
                    formatter: .short,
                    currencyCode: currencyCode
                ),
                type: type,
                action: {
                    action($0, assetData)
                }
            )
        )
    }
}
