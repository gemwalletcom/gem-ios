import SwiftUI
import Primitives
import Components
import Settings
import Store
import GRDBQuery
import Style
import Keystore

struct SelectAssetScene: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService

    @State private var isPresentingCopyMessage: Bool = false
    @State private var isPresentingCopyMessageValue: String?  = .none

    @Binding private var isPresentingAddToken: Bool

    @Query<AssetsRequest> 
    private var assets: [AssetData]
    @Query<AssetsInfoRequest>
    var assetInfo: AssetsInfo

    @State private var model: SelectAssetViewModel

    init(
        model: SelectAssetViewModel,
        isPresentingAddToken: Binding<Bool>
    ) {
        _model = State(wrappedValue: model)
        _isPresentingAddToken = isPresentingAddToken

        let request = Binding {
            model.filterModel.assetsRequest
        } set: { new in
            model.filterModel.assetsRequest = new
        }
        _assets = Query(request)
        _assetInfo =  Query(model.assetsInfoRequest)
    }

    var body: some View {
        List {
            if model.showAssetsInfo {
                if assetInfo.hidden > 0 && $assets.searchBy.wrappedValue.isEmpty {
                    NavigationLink {
                        SelectAssetScene(
                            model: SelectAssetViewModel(
                                wallet: model.wallet,
                                keystore: model.keystore,
                                selectType: .hidden,
                                assetsService: model.assetsService,
                                walletsService: model.walletsService
                            ),
                            isPresentingAddToken: $isPresentingAddToken
                        )
                    } label: {
                        ListItemView(title: Localized.Assets.hidden, subtitle: "\(assetInfo.hidden)")
                    }
                }
            }
            
            Section {
                ForEach(assets) { assetData in
                    switch model.selectType {
                    case .buy, .receive, .send, .swap, .stake:
                        NavigationLink(value: SelectAssetInput(type: model.selectType, assetAddress: assetData.assetAddress)) {
                            ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)
                        }
                    case .manage, .hidden:
                        ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: onAsset)
                    }
                }
            } footer: {
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
            
            if model.showAddToken {
                Section {
                    NavigationCustomLink(with: Text(Localized.Assets.addCustomToken)) {
                        isPresentingAddToken = true
                    }
                }
            }
        }
        .searchable(
            text: $assets.searchBy,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .debounce(value: $assets.searchBy,
                  interval: Duration.milliseconds(250),
                  action: model.search(query:))
        .modifier(ToastModifier(isPresenting: $isPresentingCopyMessage, value: isPresentingCopyMessageValue ?? "", systemImage: SystemImage.copy))
        .navigationBarTitle(model.title)
        .navigationDestination(for: SelectAssetInput.self) { input in
            switch input.type {
            case .send:
                RecipientScene(model: RecipientViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    walletsService: walletsService,
                    assetModel: AssetViewModel(asset: input.asset))
                )
            case .receive:
                ReceiveScene(
                    model: ReceiveViewModel(
                        assetModel: AssetViewModel(asset: input.asset),
                        walletId: model.wallet.walletId,
                        address: input.assetAddress.address,
                        walletsService: walletsService
                    )
                )
            case .buy:
                BuyAssetScene(
                    model: BuyAssetViewModel(
                        assetAddress: input.assetAddress,
                        input: .default)
                    )
            case .swap:
                SwapScene(model: SwapViewModel(
                        wallet: model.wallet,
                        assetId: input.asset.id,
                        walletsService: walletsService,
                        swapService: SwapService(nodeProvider: nodeService),
                        keystore: keystore
                    )
                )
            case .stake:
                StakeScene(model: StakeViewModel(
                    wallet: model.wallet,
                    chain: input.asset.id.chain,
                    stakeService: walletsService.stakeService)
                )
            case .manage, .hidden:
                EmptyView()
            }
        }
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
    @State var present: Bool = false
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
