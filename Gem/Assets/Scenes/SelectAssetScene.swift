import SwiftUI
import Primitives
import Components
import Settings
import Store
import GRDBQuery
import Style
import Keystore
import Localization
import PrimitivesComponents

struct SelectAssetScene: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService

    @State private var isPresentingCopyMessage: Bool = false
    @State private var isPresentingCopyMessageValue: String?  = .none

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
        List {
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
            } footer: {
                if model.state.isLoading || assets.isEmpty {
                    VStack {
                        if model.state.isLoading {
                            HStack {
                                LoadingView()
                            }
                        } else if assets.isEmpty {
                            Text(Localized.Assets.noAssetsFound)
                        }
                    }
                    .frame(height: 22)
                }
            }
            
            if model.showAddToken {
                Section {
                    NavigationCustomLink(with: Text(Localized.Assets.addCustomToken)) {
                        isPresentingAddToken = true
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .searchable(
            text: $assets.searchBy,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .debounce(
            value: $assets.searchBy.wrappedValue,
            interval: Duration.milliseconds(250),
            action: model.search(query:)
        )
        .onChange(of: model.filterModel.chainsFilter.selectedChains, onChangeChains)
        .modifier(ToastModifier(isPresenting: $isPresentingCopyMessage, value: isPresentingCopyMessageValue ?? "", systemImage: SystemImage.copy))
        .listSectionSpacing(.compact)
        .navigationBarTitle(model.title)
    }
    
    func assetsList(assets: [AssetData]) -> some View {
        ForEach(assets) { assetData in
            switch model.selectType {
            case .buy, .sell, .receive, .send, .stake:
                NavigationLink(value: SelectAssetInput(type: model.selectType, assetAddress: assetData.assetAddress)) {
                    ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)
                }
            case .manage:
                ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)
            case .priceAlert, .swap:
                NavigationCustomLink(with: ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)) {
                    model.selectAsset(asset: assetData.asset)
                }
            }
        }
    }
}

// MARK: - Actions

extension SelectAssetScene {
    private func onChangeChains(_ _: [Chain], _ chains: [Chain]) {
        model.update(filterRequest: .chains(chains.map({ $0.rawValue })))
    }
    
    private func onAsset(action: ListAssetItemAction, assetData: AssetData) {
        let asset = assetData.asset
        switch action {
        case .enabled(let enabled):
            model.enableAsset(assetId: asset.id, enabled: enabled)
        case .copy:
            let address = assetData.account.address
            isPresentingCopyMessage = true
            isPresentingCopyMessageValue = CopyTypeViewModel(type: .address(asset, address: address)).message
            UIPasteboard.general.string = address
            model.enableAsset(assetId: asset.id, enabled: true)
        }
    }
}

private struct ListAssetItemSelectionView: View {
    let assetData: AssetData
    let type: AssetListType
    let action: (ListAssetItemAction, AssetData) -> Void
    
    var body: some View {
        ListAssetItemView(
            model: ListAssetItemViewModel(
                showBalancePrivacy: .constant(false),
                assetDataModel: AssetDataViewModel(assetData: assetData, formatter: .short),
                type: type,
                action: {
                    action($0, assetData)
                }
            )
        )
    }
}

#Preview {
    @Previewable @State var present: Bool = false
    return NavigationStack {
        SelectAssetScene(
            model: SelectAssetViewModel(
                wallet: .main,
                keystore: LocalKeystore.main,
                selectType: .receive,
                assetsService: .main,
                walletsService: .main
            ),
            isPresentingAddToken: $present
        )
    }
}
