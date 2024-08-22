import SwiftUI
import Primitives
import Components
import Settings
import Store
import GRDBQuery
import Style

struct SelectAssetScene: View {

    @Environment(\.db) private var DB
    @Environment(\.keystore) private var keystore
    @Environment(\.walletService) private var walletService
    @Environment(\.nodeService) private var nodeService

    @State var isPresentingAddToken: Binding<Bool>
    @State private var isPresentingCopyMessage: Bool = false
    @State private var isPresentingCopyMessageValue: String?  = .none
    
    @Query<AssetsRequest>
    var assets: [AssetData]
    
    @Query<AssetsInfoRequest>
    var assetInfo: AssetsInfo
    
    @StateObject var model: SelectAssetViewModel
    
    init(
        model: SelectAssetViewModel,
        isPresentingAddToken: Binding<Bool>
    ) {
        _model = StateObject(wrappedValue: model)
        _assets = Query(model.assetRequest, in: \.db.dbQueue)
        _assetInfo =  Query(model.assetsInfoRequest, in: \.db.dbQueue)
        self.isPresentingAddToken = isPresentingAddToken
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
                                walletService: model.walletService
                            ),
                            isPresentingAddToken: isPresentingAddToken
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
                            ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: assetAction)
                        }
                    case .manage, .hidden:
                        ListAssetItemSelectionView(assetData: assetData, type: model.selectType.listType, action: assetAction)
                    }
                }
            } footer: {
                VStack {
                    if model.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
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
                        isPresentingAddToken.wrappedValue = true
                    }
                }
            }
        }
        .searchable(
            text: $assets.searchBy,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .modifier(ToastModifier(isPresenting: $isPresentingCopyMessage, value: isPresentingCopyMessageValue ?? "", systemImage: SystemImage.copy))
        .navigationBarTitle(model.title)
        .onChange(of: $assets.searchBy.wrappedValue) { _, query in
            Task {
                await model.searchQuery(query: query)
            }
        }
        .navigationDestination(for: SelectAssetInput.self) { input in
            switch input.type {
            case .send:
                RecipientScene(model: RecipientViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    walletService: walletService,
                    assetModel: AssetViewModel(asset: input.asset))
                )
            case .receive:
                ReceiveScene(
                    model: ReceiveViewModel(
                        assetModel: AssetViewModel(asset: input.asset),
                        walletId: model.wallet.walletId,
                        address: input.assetAddress.address,
                        walletService: walletService
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
                        walletService: walletService,
                        swapService: SwapService(nodeProvider: nodeService),
                        keystore: keystore
                    )
                )
            case .stake:
                StakeScene(model: StakeViewModel(
                    wallet: model.wallet,
                    chain: input.asset.id.chain,
                    stakeService: walletService.stakeService)
                )
            case .manage, .hidden:
                EmptyView()
            }
        }
    }
    
    func assetAction(_ action: ListAssetItemAction, assetData: AssetData) {
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

//struct SelectAssetScene_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectAssetScene(
//            model: SelectAssetViewModel(
//                wallet: .main,
//                keystore: .main,
//                selectType: .receive,
//                assetsService: .main,
//                walletService: .main
//            )
//        )
//    }
//}
