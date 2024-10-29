import SwiftUI
import Primitives
import Components
import Settings
import Store
import GRDBQuery
import Style
import Keystore
import Localization

struct SelectAssetScene: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService

    @State private var isPresentingCopyMessage: Bool = false
    @State private var isPresentingCopyMessageValue: String?  = .none

    @State private var model: SelectAssetViewModel

    @Query<AssetsRequest> 
    private var assets: [AssetData]

    init(model: SelectAssetViewModel) {
        _model = State(wrappedValue: model)

        let request = Binding {
            model.filterModel.assetsRequest
        } set: { new in
            model.filterModel.assetsRequest = new
        }
        _assets = Query(request)
    }

    var body: some View {
        List {
            Section {
                ForEach(assets) { assetData in
                    switch model.selectType {
                    case .buy, .receive, .send, .swap, .stake:
                        NavigationLink(value: SelectAssetInput(type: model.selectType, assetAddress: assetData.assetAddress)) {
                            ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)
                        }
                    case .manage:
                        ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)
                    case .priceAlert:
                        NavigationCustomLink(with: ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)) {
                            model.selectAsset(asset: assetData.asset)
                        }
                    }
                }
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
                    NavigationLink(value: Scenes.AddToken()) {
                        Text(Localized.Assets.addCustomToken)
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
            value: $assets.searchBy,
            interval: Duration.milliseconds(250),
            action: model.search(query:)
        )
        .modifier(ToastModifier(isPresenting: $isPresentingCopyMessage, value: isPresentingCopyMessageValue ?? "", systemImage: SystemImage.copy))
        .listSectionSpacing(.compact)
        .navigationBarTitle(model.title)
    }
}

// MARK: - Actions

extension SelectAssetScene {
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
            )
        )
    }
}
