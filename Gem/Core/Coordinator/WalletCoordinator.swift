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

struct WalletCoordinator: View {
    let db: DB

    @State var navigationStateManager: NavigationStateManagable
    @ObservedObject var keystore: LocalKeystore = .main

    @State var walletConnectManager: WalletConnectManager
    @State var lockModel: LockSceneViewModel

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
    let walletConnectorSigner: WalletConnectorSigner
    let walletConnectorInteractor: WalletConnectorInteractor
    
    let preferences = Preferences()
    let onstartService: OnstartAsyncService

    let pricesTimer = Timer.publish(every: 600, tolerance: 1, on: .main, in: .common).autoconnect()

    @State var isPresentingError: String? = .none
    @State private var updateAvailableAlertSheetMessage: String? = .none

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

        _navigationStateManager = State(initialValue: NavigationStateManager(initialSelecedTab: .wallet))
        _walletConnectManager = State(initialValue: WalletConnectManager(
            connectionsService: connectionsService,
            keystore: _keystore.wrappedValue)
        )
        _lockModel = State(initialValue: LockSceneViewModel())
    }
    
    var body: some View {
        VStack {
            if let currentWallet = keystore.currentWallet {
                LockScreenScene(model: lockModel) {
                    MainTabView(
                        model: .init(wallet: currentWallet),
                        navigationStateManager: $navigationStateManager
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
                    .environment(\.chainServiceFactory, chainServiceFactory)
                }
            } else {
                WelcomeScene(model: WelcomeViewModel(keystore: keystore))
            }
        }
        .onChange(of: lockModel.shouldShowPlaceholder) { _, show in
            if show {
                walletConnectManager.setRequestsPending()
            } else {
                walletConnectManager.processPendingRequests()
            }
        }
        .onOpenURL(perform: { url in
            Task {
                await handleUrl(url: url)
            }
            
            //isPresentingError = url.absoluteString
        })
        .sheet(item: $walletConnectManager.transferData) { data in
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
                            walletConnectManager.cancelTransferData()
                        }
                        .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(item: $walletConnectManager.signMessage) { data in
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
                            walletConnectManager.cancelSignMessage()
                        }
                        .bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(item: $walletConnectManager.connectionProposal) { data in
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
                            walletConnectManager.cancelConnectionProposal()
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
        .onReceive(pricesTimer) { time in
            runUpdatePrices()
        }
        .modifier(
            ToastModifier(
                isPresenting: $walletConnectManager.isPresentingWalletConnectBar,
                value: "\(Localized.WalletConnect.brandName)...",
                systemImage: SystemImage.network
            )
        )
    }

    private func runUpdatePrices() {
        NSLog("runUpdatePrices")
        Task {
            try await walletsService.updatePrices()
        }
    }

    private func handleUrl(url: URL) async {
        do {
            let urlAction = try URLParser.from(url: url)
            try await walletConnectManager.handle(action: urlAction)
        } catch {
            NSLog("handleUrl error: \(error)")
            isPresentingError = error.localizedDescription
        }
    }
}
