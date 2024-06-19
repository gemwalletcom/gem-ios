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
    
    @Environment(\.scenePhase) var scenePhase
    
    let db: DB

    @State var navigationStateManager: NavigationStateManagable
    @ObservedObject var keystore: LocalKeystore = .main
    
    let assetStore: AssetStore
    let balanceStore: BalanceStore
    let priceStore: PriceStore
    let transactionStore: TransactionStore
    let nodeStore: NodeStore
    let walletStore: WalletStore
    let stakeStore: StakeStore
    let connectionsStore: ConnectionsStore
    
    let assetsService: AssetsService
    let balanceService: BalanceService
    let stakeService: StakeService
    let priceService: PriceService
    let transactionService: TransactionService
    let walletService: WalletService
    let chainServiceFactory: ChainServiceFactory
    let nodeService: NodeService
    let subscriptionService: SubscriptionService
    let deviceService: DeviceService
    let transactionsService: TransactionsService
    let connectionsService: ConnectionsService
    let walletConnectorSigner: WalletConnectorSigner
    let walletConnectorInteractor: WalletConnectorInteractor
    
    let preferences = Preferences()
    let onstartService: OnstartAsyncService
    
    let transactionsTimer = Timer.publish(every: 5, tolerance: 1, on: .main, in: .common).autoconnect()
    let pricesTimer = Timer.publish(every: 600, tolerance: 1, on: .main, in: .common).autoconnect()

    @State private var updateAvailableAlertSheetMessage: String? = .none
    @State var isPresentingError: String? = .none
    @State var walletModel: WalletSceneViewModel
    @State var isPresentingWalletConnectBar: Bool = false

    @State var transferData: TransferDataCallback<TransferData>? // wallet connector
    @State var signMessage: TransferDataCallback<SignMessagePayload>? // wallet connector
    @State var connectionProposal: TransferDataCallback<WalletConnectionSessionProposal>? // wallet connector

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
            assetsService: assetsService
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
        self.walletService = WalletService(
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
        self.onstartService = OnstartAsyncService(
            assetStore: assetStore,
            keystore: _keystore.wrappedValue,
            nodeStore: nodeStore,
            preferences: preferences,
                assetsService: assetsService,
            deviceService: deviceService,
            subscriptionService: subscriptionService
        )
        self.deviceService.observer()
        _walletModel = State(wrappedValue: WalletSceneViewModel(
            assetsService: assetsService,
            walletService: walletService
        ))

        self.navigationStateManager = NavigationStateManager(initialSelecedTab: .wallet)
    }
    
    var body: some View {
        VStack {
            if let wallet = keystore.currentWallet {
                MainTabView(
                    wallet: wallet,
                    walletModel: walletModel,
                    keystore: keystore,
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
                .environment(\.db, db)
                .environment(\.nodeService, nodeService)
                .environment(\.keystore, keystore)
                .environment(\.walletService, walletService)
                .environment(\.deviceService, deviceService)
                .environment(\.subscriptionService, subscriptionService)
                .environment(\.transactionsService, transactionsService)
                .environment(\.assetsService, assetsService)
                .environment(\.stakeService, stakeService)
                .environment(\.chainServiceFactory, chainServiceFactory)
            } else {
                WelcomeScene(model: WelcomeViewModel(keystore: keystore))
            }
        }
        .onOpenURL(perform: { url in
            Task {
                await handleUrl(url: url)
            }
            
            //isPresentingError = url.absoluteString
        })
        .onChange(of: scenePhase) {
            switch scenePhase {
                case .inactive:
                    NSLog("WalletCoordinator: inactive")
                    //lockStateService.state = .locked
                case .active:
//                    if lockStateService.state == .locked {
//                        lockStateService.state = .unlocked
//                    }
                    NSLog("WalletCoordinator: active")
                case .background:
                    //lockStateService.state = .locked
                    NSLog("WalletCoordinator: background")
            @unknown default:
                NSLog("WalletCoordinator: unknown state")
            }
        }
        .sheet(item: $transferData) { data in
            NavigationStack {
                ConfirmTransferScene(
                    model: ConfirmTransferViewModel(
                        wallet: keystore.currentWallet!,
                        keystore: keystore,
                        data: data.payload,
                        service: ChainServiceFactory(nodeProvider: nodeService)
                            .service(for: data.payload.recipientData.asset.chain),
                        walletService: walletService,
                        confirmTransferDelegate: data.delegate
                    )
                )
                .interactiveDismissDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.cancel) {
                            transferData?.delegate(.failure(AnyError("User cancelled")))
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
                            signMessage?.delegate(.failure(AnyError("User cancelled")))
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
                        confirmTransferDelegate: data.delegate,
                        payload: data.payload
                    )
                )
                .interactiveDismissDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.cancel) {
                            connectionProposal?.delegate(.failure(AnyError("User cancelled")))
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
            runMigrations()
            runPendingTransactions()
            Task {
                await connectionsService.setup()
            }
            
            self.walletConnectorSigner.walletConnectorInteractor = self
        }
        .onReceive(transactionsTimer) { time in
            runPendingTransactions()
        }
        .onReceive(pricesTimer) { time in
            runUpdatePrices()
        }
        .modifier(
            ToastModifier(isPresenting: $isPresentingWalletConnectBar, value: "\(Localized.WalletConnect.brandName)...", systemImage: SystemImage.network)
        )
    }
    
    func runMigrations() {
        Task {
            await onstartService.migrations()
        }
    }
    
    func runPendingTransactions() {
        //NSLog("pending transactions: run")
        Task {
            try await walletService.updatePendingTransactions()
        }
    }
    
    func runUpdatePrices() {
        NSLog("runUpdatePrices")
        Task {
            try await walletService.updatePrices()
        }
    }

    func handleUrl(url: URL) async {
        do {
            let url = try URLParser.from(url: url)
            //TODO: Show loading indicator of connecting to WC
            switch url {
            case .walletConnect(let uri):
                isPresentingWalletConnectBar = true
                try await connectionsService.addConnectionURI(uri: uri, wallet: keystore.currentWallet!)

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
