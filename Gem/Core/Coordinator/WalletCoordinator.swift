import Foundation
import SwiftUI
import Keystore
import Store
import Blockchain
import Settings
import Primitives
import WalletConnector
import Components
import Style
import GemstonePrimitives
import Localization

struct WalletCoordinator: View {
    let db: DB

    @ObservedObject var keystore: LocalKeystore = .main

    let assetStore: AssetStore
    let balanceStore: BalanceStore
    let priceStore: PriceStore
    let transactionStore: TransactionStore
    let nodeStore: NodeStore
    let walletStore: WalletStore
    let stakeStore: StakeStore
    let connectionsStore: ConnectionsStore
    let bannerStore: BannerStore
    let priceAlertStore: PriceAlertStore

    let assetsService: AssetsService
    let balanceService: BalanceService
    let stakeService: StakeService
    let priceService: PriceService
    let transactionService: TransactionService
    let walletService: WalletService
    let walletsService: WalletsService
    let chainServiceFactory: ChainServiceFactory
    let nodeService: NodeService
    let subscriptionService: SubscriptionService
    let deviceService: DeviceService
    let bannerSetupService: BannerSetupService
    let transactionsService: TransactionsService
    let connectionsService: ConnectionsService
    let bannerService: BannerService
    let priceAlertService: PriceAlertService
    let notificationService = NotificationService.main

    let walletConnectorSigner: WalletConnectorSigner
    let walletConnectorInteractor: WalletConnectorInteractor
    
    let preferences = Preferences()
    let onstartService: OnstartAsyncService
    let navigationState: NavigationStateManager = NavigationStateManager.defaultValue

    @State var isPresentingError: String? = .none
    @State private var updateAvailableAlertSheetMessage: String? = .none
    @State var isPresentingWalletConnectBar: Bool = false

    @State var transferData: TransferDataCallback<WCTransferData>? // wallet connector
    @State var signMessage: TransferDataCallback<SignMessagePayload>? // wallet connector
    @State var connectionProposal: TransferDataCallback<WCPairingProposal>? // wallet connector

    init(
        db: DB
    ) {
        self.db = db
        self.assetStore = AssetStore(db: db)
        self.balanceStore = BalanceStore(db: db)
        self.priceStore = PriceStore(db: db)
        self.transactionStore = TransactionStore(db: db)
        self.nodeStore = NodeStore(db: db)
        self.walletStore = WalletStore(db: db)
        self.connectionsStore = ConnectionsStore(db: db)
        self.stakeStore = StakeStore(db: db)
        self.bannerStore = BannerStore(db: db)
        self.priceAlertStore = PriceAlertStore(db: db)
        self.nodeService = NodeService(nodeStore: nodeStore)
        self.chainServiceFactory = ChainServiceFactory(nodeProvider: nodeService)
        self.assetsService = AssetsService(
            assetStore: assetStore,
            balanceStore: balanceStore,
            chainServiceFactory: chainServiceFactory
        )
        self.balanceService = BalanceService(
            balanceStore: balanceStore,
            chainServiceFactory: chainServiceFactory
        )
        self.stakeService = StakeService(
            store: stakeStore,
            chainServiceFactory: chainServiceFactory
        )
        self.priceService = PriceService(priceStore: priceStore)
        self.transactionService = TransactionService(
            transactionStore: transactionStore,
            stakeService: stakeService,
            chainServiceFactory: chainServiceFactory,
            balanceUpdater: balanceService
        )
        self.transactionsService = TransactionsService(
            transactionStore: transactionStore,
            assetsService: assetsService,
            keystore: _keystore.wrappedValue
        )
        self.walletConnectorInteractor = WalletConnectorInteractor()
        self.walletConnectorSigner = WalletConnectorSigner(
            store: connectionsStore,
            keystore: _keystore.wrappedValue,
            walletConnectorInteractor: walletConnectorInteractor
        )
        self.connectionsService = ConnectionsService(
            store: connectionsStore,
            signer: walletConnectorSigner
        )
        self.bannerService = BannerService(store: bannerStore)
        self.walletService = WalletService(keystore: _keystore.wrappedValue, walletStore: walletStore)
        self.walletsService = WalletsService(
            keystore: _keystore.wrappedValue,
            priceStore: priceStore,
            assetsService: assetsService,
            balanceService: balanceService,
            stakeService: stakeService,
            priceService: priceService,
            discoverAssetService: DiscoverAssetsService(
                balanceService: balanceService,
                chainServiceFactory: chainServiceFactory
            ),
            transactionService: transactionService,
            nodeService: nodeService,
            connectionsService: connectionsService
        )
        self.subscriptionService = SubscriptionService(walletStore: walletStore)
        self.deviceService = DeviceService(subscriptionsService: subscriptionService, walletStore: walletStore)
        self.bannerSetupService = BannerSetupService(store: bannerStore)
        self.priceAlertService = PriceAlertService(
            store: priceAlertStore,
            deviceService: deviceService
        )
        self.onstartService = OnstartAsyncService(
            assetStore: assetStore,
            keystore: _keystore.wrappedValue,
            nodeStore: nodeStore,
            preferences: preferences,
                assetsService: assetsService,
            deviceService: deviceService,
            subscriptionService: subscriptionService,
            bannerSetupService: bannerSetupService
        )
        self.deviceService.observer()
    }
    
    var body: some View {
        VStack {
            if let currentWallet = keystore.currentWallet {
                MainTabView(
                    model: .init(wallet: currentWallet)
                )
                .tint(Colors.black)
                .alert(Localized.UpdateApp.title, isPresented: $updateAvailableAlertSheetMessage.mappedToBool()) {
                    Button(Localized.Common.cancel, role: .cancel) { }
                    Button(Localized.UpdateApp.action, role: .none) {
                        UIApplication.shared.open(PublicConstants.url(.appStore))
                    }
                } message: {
                    Text(Localized.UpdateApp.description(updateAvailableAlertSheetMessage ?? ""))
                }
                .environment(\.nodeService, nodeService)
                .environment(\.keystore, keystore)
                .environment(\.walletService, walletService)
                .environment(\.walletsService, walletsService)
                .environment(\.deviceService, deviceService)
                .environment(\.subscriptionService, subscriptionService)
                .environment(\.transactionsService, transactionsService)
                .environment(\.assetsService, assetsService)
                .environment(\.stakeService, stakeService)
                .environment(\.bannerService, bannerService)
                .environment(\.balanceService, balanceService)
                .environment(\.priceAlertService, priceAlertService)
                .environment(\.notificationService, notificationService)
                .environment(\.chainServiceFactory, chainServiceFactory)
                .environment(\.navigationState, navigationState)
            } else {
                WelcomeScene(model: WelcomeViewModel())
            }
        }
        .onOpenURL(perform: { url in
            Task {
                await handleUrl(url: url)
            }
        })
        .sheet(item: $transferData) { data in
            NavigationStack {
                ConfirmTransferScene(
                    model: ConfirmTransferViewModel(
                        wallet: data.payload.wallet,
                        keystore: keystore,
                        data: data.payload.tranferData,
                        service: ChainServiceFactory(nodeProvider: nodeService)
                            .service(for: data.payload.tranferData.recipientData.asset.chain),
                        walletsService: walletsService,
                        confirmTransferDelegate: data.delegate
                    )
                )
                .interactiveDismissDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.cancel) {
                            transferData?.delegate(.failure(ConnectionsError.userCancelled))
                            transferData = nil
                        }
                        .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(item: $signMessage) { data in
            NavigationStack {
                SignMessageScene(
                    model: SignMessageSceneViewModel(
                        keystore: keystore,
                        payload: data.payload,
                        confirmTransferDelegate: data.delegate
                    )
                )
                .interactiveDismissDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.cancel) {
                            signMessage?.delegate(.failure(ConnectionsError.userCancelled))
                            signMessage = nil
                        }
                        .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(item: $connectionProposal) { data in
            NavigationStack {
                ConnectionProposalScene(
                    model: ConnectionProposalViewModel(
                        connectionsService: connectionsService,
                        confirmTransferDelegate: data.delegate,
                        pairingProposal: data.payload,
                        wallets: keystore.wallets
                    )
                )
                .interactiveDismissDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.cancel) {
                            connectionProposal?.delegate(.failure(ConnectionsError.userCancelled))
                            connectionProposal = nil
                        }
                        .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .confirmationDialog(
            Text(Localized.WalletConnect.brandName), isPresented: $isPresentingError.mappedToBool(), 
            actions: {
                Button(Localized.Common.done, role: .none) {
                    
                }
        }, message: {
            Text(isPresentingError.valueOrEmpty)
        })
        .taskOnce {
            onstartService.updateVersionAction = {
                updateAvailableAlertSheetMessage = $0
            }
            onstartService.setup()
            transactionService.setup()
            connectionsService.setup()

            if let wallet = keystore.currentWallet {
                onstartService.setup(wallet: wallet)
            }
            self.walletConnectorSigner.walletConnectorInteractor = self
        }
        .onChange(of: keystore.currentWallet) { _, newValue in
            if let newValue {
                onstartService.setup(wallet: newValue)
            }
        }
        .modifier(
            ToastModifier(
                isPresenting: $isPresentingWalletConnectBar,
                value: "\(Localized.WalletConnect.brandName)...",
                systemImage: SystemImage.network
            )
        )
    }

    private func handleUrl(url: URL) async {
        do {
            let url = try URLParser.from(url: url)
            switch url {
            case .walletConnect(let uri):
                isPresentingWalletConnectBar = true
                try await connectionsService.addConnectionURI(
                    uri: uri,
                    wallet: try keystore.getCurrentWallet()
                )
            case .walletConnectRequest:
                isPresentingWalletConnectBar = true
                break
            }
        } catch {
            NSLog("handleUrl error: \(error)")
            isPresentingError = error.localizedDescription
        }
    }
}
