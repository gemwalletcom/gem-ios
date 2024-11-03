// Copyright (c). Gem Wallet. All rights reserved.

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
import Intro
import BannerService
import NotificationService
import DeviceService
import PriceAlertService
import GemAPI
import ChainService
import StakeService

struct WalletCoordinator: View {
    let db: DB

    @ObservedObject var keystore: LocalKeystore = .main

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
    let deviceObserverService: DeviceObserverService
    let bannerSetupService: BannerSetupService
    let transactionsService: TransactionsService
    let connectionsService: ConnectionsService
    let bannerService: BannerService
    let priceAlertService: PriceAlertService
    let notificationService = NotificationService.main
    let apiService = GemAPIService.shared
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
        let storeManager = StoreManager(db: db)
        
        self.nodeService = NodeService(nodeStore: storeManager.nodeStore)
        self.chainServiceFactory = ChainServiceFactory(nodeProvider: nodeService)
        self.assetsService = AssetsService(
            assetStore: storeManager.assetStore,
            balanceStore: storeManager.balanceStore,
            chainServiceFactory: chainServiceFactory
        )
        self.balanceService = BalanceService(
            balanceStore: storeManager.balanceStore,
            chainServiceFactory: chainServiceFactory
        )
        self.stakeService = StakeService(
            store: storeManager.stakeStore,
            chainServiceFactory: chainServiceFactory
        )
        self.priceService = PriceService(priceStore: storeManager.priceStore, preferences: preferences)
        self.transactionService = TransactionService(
            transactionStore: storeManager.transactionStore,
            stakeService: stakeService,
            chainServiceFactory: chainServiceFactory,
            balanceUpdater: balanceService
        )
        self.transactionsService = TransactionsService(
            transactionStore: storeManager.transactionStore,
            assetsService: assetsService,
            keystore: _keystore.wrappedValue
        )
        self.walletConnectorInteractor = WalletConnectorInteractor()
        self.walletConnectorSigner = WalletConnectorSigner(
            store: storeManager.connectionsStore,
            keystore: _keystore.wrappedValue,
            walletConnectorInteractor: walletConnectorInteractor
        )
        self.connectionsService = ConnectionsService(
            store: storeManager.connectionsStore,
            signer: walletConnectorSigner
        )
        self.bannerService = BannerService(
            store: storeManager.bannerStore,
            pushNotificationService: PushNotificationEnablerService(preferences: preferences)
        )
        self.walletService = WalletService(keystore: _keystore.wrappedValue, walletStore: storeManager.walletStore)
        self.bannerSetupService = BannerSetupService(store: storeManager.bannerStore, preferences: preferences)
        self.walletsService = WalletsService(
            keystore: _keystore.wrappedValue,
            priceStore: storeManager.priceStore,
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
            connectionsService: connectionsService,
            bannerSetupService: bannerSetupService,
            addressStatusService: AddressStatusService(chainServiceFactory: chainServiceFactory)
        )
        self.subscriptionService = SubscriptionService(subscriptionProvider: apiService, walletStore: storeManager.walletStore)
        self.deviceService = DeviceService(deviceProvider: apiService, subscriptionsService: subscriptionService)
        self.deviceObserverService = DeviceObserverService(
            deviceService: deviceService,
            subscriptionsService: subscriptionService,
            subscriptionsObserver: storeManager.walletStore.observer()
        )
        
        self.priceAlertService = PriceAlertService(
            store: storeManager.priceAlertStore,
            deviceService: deviceService,
            preferences: preferences
        )
        self.onstartService = OnstartAsyncService(
            assetStore: storeManager.assetStore,
            keystore: _keystore.wrappedValue,
            nodeStore: storeManager.nodeStore,
            preferences: preferences,
                assetsService: assetsService,
            deviceService: deviceService,
            subscriptionService: subscriptionService,
            bannerSetupService: bannerSetupService
        )
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
                IntroNavigationView()
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
                        confirmTransferDelegate: data.delegate,
                        onComplete: {
                            transferData = nil
                        }
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
            deviceObserverService.startSubscriptionsObserver()

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
