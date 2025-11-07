// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import GRDB
import GRDBQuery
import Store
import Localization
import Style
import NFT
import TransactionsService
import WalletTab
import Transactions
import Swap
import Assets

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.walletsService) private var walletsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.notificationHandler) private var notificationHandler
    @Environment(\.bannerService) private var bannerService
    @Environment(\.navigationState) private var navigationState
    @Environment(\.nftService) private var nftService
    @Environment(\.priceService) private var priceService
    @Environment(\.priceObserverService) private var priceObserverService
    @Environment(\.observablePreferences) private var observablePreferences
    @Environment(\.walletService) private var walletService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.perpetualObserverService) private var perpetualObserverService

    private let model: MainTabViewModel

    @Query<TransactionsCountRequest>
    private var transactions: Int

    private var tabViewSelection: Binding<TabItem> {
        Binding(
            get: { navigationState.selectedTab },
            set: { onSelect(tab: $0) }
        )
    }

    @State private var isPresentingSelectedAssetInput: SelectedAssetInput?
    @State private var isPresentingSupport = false

    init(model: MainTabViewModel) {
        self.model = model
        _transactions = Query(constant: model.transactionsCountRequest)
    }

    var body: some View {
        TabView(selection: tabViewSelection) {
            WalletNavigationStack(
                model: WalletSceneViewModel(
                    walletsService: walletsService,
                    bannerService: bannerService,
                    walletService: walletService,
                    observablePreferences: observablePreferences,
                    wallet: model.wallet,
                    isPresentingSelectedAssetInput: $isPresentingSelectedAssetInput
                )
            )
            .tabItem {
                tabItem(Localized.Wallet.title, Images.Tabs.wallet)
            }
            .tag(TabItem.wallet)
            
            if model.isMarketEnabled {
                MarketsNavigationStack()
                .tabItem {
                    tabItem("Markets", Images.Tabs.markets)
                }
                .tag(TabItem.markets)
            }
            
            if model.isCollectionsEnabled {
                CollectionsNavigationStack(
                    model: CollectionsViewModel(
                        nftService: nftService,
                        walletService: walletService,
                        wallet: model.wallet,
                        sceneStep: .collections,
                        isPresentingSelectedAssetInput: $isPresentingSelectedAssetInput
                    )
                )
                .tabItem {
                    tabItem(Localized.Nft.collections, Images.Tabs.collections)
                }
                .tag(TabItem.collections)
            }
            
            TransactionsNavigationStack(
                model: TransactionsViewModel(
                    transactionsService: transactionsService,
                    walletService: walletService,
                    wallet: model.wallet,
                    type: .all
                )
            )
            .tabItem {
                tabItem(Localized.Activity.title, Images.Tabs.activity)
            }
            .badge(transactions)
            .tag(TabItem.activity)

            SettingsNavigationStack(
                walletId: model.wallet.walletId,
                priceService: priceService,
                isPresentingSupport: $isPresentingSupport
            )
            .tabItem {
                tabItem(Localized.Settings.title, Images.Tabs.settings)
            }
            .tag(TabItem.settings)
        }
        .sheet(item: $isPresentingSelectedAssetInput) { input in
            SelectedAssetNavigationStack(
                input: input,
                wallet: model.wallet,
                onComplete: { onComplete(type: input.type) }
            )
        }
        .onChange(of: model.walletId, onWalletIdChange)
        .onChange(
            of: notificationHandler.notifications,
            initial: true,
            onReceiveNotifications
        )
        .taskOnce {
            Task {
                await connectObservers()
            }
        }
        .onChange(of: scenePhase) { (oldScene, newPhase) in
            switch newPhase {
            case .active:
                Task {
                    await connectObservers()
                }
                #debugLog("App moved to active — restart websocket, refresh UI…")
            case .inactive:
                Task {
                    await disconnectObservers()
                }
                #debugLog("App is inactive — e.g. transitioning or showing interruption UI")
            case .background:
                #debugLog("App went to background — tear down connections, save state…")
            @unknown default:
                break
            }
        }
    }
}

// MARK: - UI Components

extension MainTabView {
    @ViewBuilder
    private func tabItem(_ title: String, _ image: Image) -> Label<Text, Image> {
        Label(
            title: { Text(title) },
            icon: { image }
        )
    }
}

// MARK: - Actions

extension MainTabView {
    private func onSelect(tab: TabItem) {
        navigationState.select(tab: tab)
    }

    private func onReceiveNotifications(_: [PushNotification], _ notifications: [PushNotification]) {
        if let notification = notifications.first {
            Task {
                await onReceiveNotification(notification: notification)
            }
        }
        notificationHandler.clear()
    }

    private func onReceiveNotification(notification: PushNotification) async {
        do {
            switch notification {
            case let .transaction(walletIndex, assetId, transaction):
                guard let walletId = walletService.setCurrent(for: walletIndex) else {
                    return
                }

                let asset = try await assetsService.getOrFetchAsset(for: assetId)
                var path = NavigationPath()
                path.append(Scenes.Asset(asset: asset))

                try transactionsService.addTransaction(walletId: walletId, transaction: transaction)
                let transaction = try transactionsService.getTransaction(
                    walletId: walletId,
                    transactionId: transaction.id.identifier
                )
                path.append(transaction)

                navigationState.wallet = path
            case .priceAlert(let assetId):
                let asset = try await assetsService.getOrFetchAsset(for: assetId)
                navigationState.wallet.append(Scenes.Price(asset: asset))
            case .asset(let assetId), .buyAsset(let assetId):
                let asset = try await assetsService.getOrFetchAsset(for: assetId)
                navigationState.wallet.append(Scenes.Asset(asset: asset))
            case let .swapAsset(fromAsetId, toAssetId):
                async let getFromAsset = try await assetsService.getOrFetchAsset(for: fromAsetId)
                async let getToAsset: Asset? = {
                    guard let id = toAssetId else { return nil }
                    return try await assetsService.getOrFetchAsset(for: id)
                }()

                let (fromAsset, toAsset) = try await (getFromAsset, getToAsset)
                let account = try model.wallet.account(for: fromAsset.chain)

                isPresentingSelectedAssetInput = SelectedAssetInput(
                    type: .swap(fromAsset, toAsset),
                    assetAddress: AssetAddress(
                        asset: account.chain.asset,
                        address: account.address
                    )
                )
                return
            case .support:
                isPresentingSupport = true
            case .test, .unknown:
                break
            }

            if let selectTab = notification.selectTab {
                navigationState.selectedTab = selectTab
            }
        } catch {
            #debugLog("onReceiveNotification error \(error)")
        }
    }

    private func onWalletIdChange() {
        navigationState.clearAll()
        navigationState.selectedTab = .wallet
        
        Task {
            try await priceObserverService.setupAssets()
            await perpetualObserverService.connect(for: model.wallet)
        }
    }
    
    private func connectObservers() async {
        await priceObserverService.connect()
        await perpetualObserverService.connect(for: model.wallet)
    }
    
    private func disconnectObservers() async {
        await priceObserverService.disconnect()
        await perpetualObserverService.disconnect()
    }

    private func onComplete(type: SelectedAssetType) {
        switch type {
        case .receive, .stake, .buy, .sell:
            isPresentingSelectedAssetInput = nil
        case let .send(type):
            switch type {
            case .nft:
                if navigationState.selectedTab == .collections {
                    navigationState.collections.removeAll()
                    navigationState.activity.removeAll()
                    navigationState.selectedTab = .activity
                }
            case .asset:
                break
            }
            isPresentingSelectedAssetInput = nil
        case let .swap(fromAsset, _):
            Task {
                let asset = try await assetsService.getOrFetchAsset(for: fromAsset.id)

                switch navigationState.selectedTab {
                case .wallet:
                    navigationState.wallet = NavigationPath([Scenes.Asset(asset: asset)])
                case .activity:
                    navigationState.wallet = NavigationPath([Scenes.Asset(asset: asset)])
                    navigationState.selectedTab = .wallet
                case .markets, .settings, .collections:
                    break
                }
                isPresentingSelectedAssetInput = nil
            }
        }
    }
}

extension PushNotification {
    var selectTab: TabItem? {
        switch self {
        case .transaction, .asset, .priceAlert, .buyAsset, .swapAsset: .wallet
        case .support: .settings
        case .test, .unknown: nil
        }
    }
}
