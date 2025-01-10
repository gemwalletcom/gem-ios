// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import Primitives
import Store
import GemAPI
import Combine
import Settings
import Keystore
import ChainService
import BannerService
import StakeService
import NodeService
import PriceService

class WalletsService {
    
    let keystore: any Keystore
    let assetsService: AssetsService
    let balanceService: BalanceService
    let priceService: PriceService
    let addressStatusService: AddressStatusService

    private let discoverAssetService: DiscoverAssetsService
    private let transactionService: TransactionService
    private let bannerSetupService: BannerSetupService
    private let preferences: Preferences

    private var assetObserver: AnyCancellable?
    private var balanceObserver: AnyCancellable?
    private var balanceErrorsObserver: AnyCancellable?
    
    init(
        keystore: any Keystore,
        priceStore: PriceStore,
        assetsService: AssetsService,
        balanceService: BalanceService,
        priceService: PriceService,
        discoverAssetService: DiscoverAssetsService,
        transactionService: TransactionService,
        bannerSetupService: BannerSetupService,
        addressStatusService: AddressStatusService,
        preferences: Preferences = Preferences.main
    ) {
        self.keystore = keystore
        self.assetsService = assetsService
        self.balanceService = balanceService
        self.priceService = priceService
        self.discoverAssetService = discoverAssetService
        self.transactionService = transactionService
        self.bannerSetupService = bannerSetupService
        self.addressStatusService = addressStatusService
        self.preferences = preferences

        defer {
            self.balanceObserver = balanceService.observeBalance().sink { update in
                for balance in update.balances {
                    NSLog("observe balance: \(balance.assetId.identifier): \(balance.type)")
                }
                try? self.storeBalances(update: update)
            }
            self.assetObserver = discoverAssetService.observeAssets().sink { update in
                NSLog("discover assets: \(update.wallet.name): \(update.assets)")
                
                do {
                    try self.addNewAssets(walletId: update.wallet.walletId, assetIds: update.assets.compactMap { try? AssetId(id: $0) })
                } catch {
                    NSLog("newAssetUpdate error: \(error)")
                }
            }
            self.balanceErrorsObserver = balanceService.observeBalanceErrors().sink { update in
                NSLog("observe balance error: \(update.chain.id): \(update.error.localizedDescription)")
            }
        }
    }
    
    func changeCurrency(walletId: WalletId) async throws {
        // TODO: - here need a cancel logic if updatePrices & updateBalance in progress, but someone changes in one more time
        // updates prices
        try priceService.clear()
        let assetIds = try assetsService.getAssets().assetIds
        try await updatePrices(assetIds: assetIds)
        // update balances
        let enabledAssetIds = try assetsService.getEnabledAssets()
        try await updateBalance(for: walletId, assetIds: enabledAssetIds)
    }
    
    func update(walletId: WalletId) async throws {
        let assetIds = try assetsService
            .getAssets(walletID: walletId.id, filters: [.enabled])
            .map { $0.asset.id }
        try await fetch(walletId: walletId, assetIds: assetIds)
    }
    
    func updateAsset(walletId: WalletId, assetId: AssetId) async throws {
        async let getBalance: () = try updateBalance(for: walletId, assetIds: [assetId])
        async let getPrice: () = try updatePrices(assetIds: [assetId])
        
        let (_, _) =  try await (getBalance, getPrice)
    }
    
    func fetch(walletId: WalletId, assetIds: [AssetId]) async throws {
        let wallet = try keystore.getWallet(walletId)
        async let balances: () = try updateBalance(for: walletId, assetIds: assetIds)
        async let prices: () = try updatePrices(assetIds: assetIds)
        async let newAssets: () = try getNewAssets(for: wallet)
        let _ = try await [balances, prices, newAssets]
    }

    func updateBalance(for walletId: WalletId, assetIds: [AssetId]) async throws {
        NSLog("fetch balances: \(assetIds.count)")
        
        let wallet = try keystore.getWallet(walletId)
        balanceService.updateBalance(for: wallet, assetIds: assetIds)
    }
    
    func storeBalances(update: BalanceUpdate) throws {
        let assetIds = update.balances.map { $0.assetId }
        let assets = try assetsService.getAssets(for: assetIds)
        let updates = balanceService.createBalanceUpdate(assets: assets, balances: update.balances)
        try? balanceService.updateBalances(updates, walletId: update.walletId)
    }
    
    func updatePrices() async throws {
        let assetIds = try assetsService.getEnabledAssets()
        try await updatePrices(assetIds: assetIds)
    }
    
    func updatePrices(assetIds: [AssetId]) async throws {
        NSLog("fetch prices. assetIds: \(assetIds.count)")
        
        let prices = try await priceService.fetchPrices(for: assetIds.ids, currency: self.preferences.currency)
        try priceService.updatePrices(prices: prices)
    }
    
    // add asset to asset store and create balance store record
    func addAssetsBalancesIfMissing(assetIds: [AssetId], wallet: Wallet) throws {
        try balanceService.addAssetsBalancesIfMissing(assetIds: assetIds, wallet: wallet)
    }
    
    func getNewAssets(for wallet: Wallet) async throws {
        guard wallet.hasTokenSupport else { return }

        let preferences = wallet.preferences
        
        Task {
            if !preferences.completeInitialLoadAssets {
                await discoverAssetService.updateCoins(wallet: wallet)
                preferences.completeInitialLoadAssets = true
            }
        }
        
        //FIXME: temp solution to wait for 1 second (need to wait until subscriptions updated)
        //otherwise it would return no assets
        try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
        
        let deviceId = try SecurePreferences.standard.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        
        Task {
            try await discoverAssetService.updateTokens(
                deviceId: deviceId,
                wallet: wallet,
                fromTimestamp: preferences.assetsTimestamp
            )
            preferences.assetsTimestamp = newTimestamp
        }
    }
    
    // add fresh new asset: fetch asset and then activate balance
    func addNewAssets(walletId: WalletId, assetIds: [AssetId]) throws {
        let assets = try assetsService.getAssets(for: assetIds)
        let missingIds = assetIds.asSet().subtracting(assets.map { $0.id }.asSet())
        
        // enable that already exist in db
        if !assets.isEmpty {
            enableAssetId(walletId: walletId, assets: assets.assetIds, enabled: true)
        }
        
        // fetch and enable
        for assetId in missingIds {
            Task {
                try await assetsService.updateAsset(assetId: assetId)
                enableAssetId(walletId: walletId, assets: [assetId], enabled: true)
            }
        }
    }
    
    func enableAssetId(walletId: WalletId, assets: [AssetId], enabled: Bool) {
        do {
            for assetId in assets {
                try assetsService.addBalanceIfMissing(walletId: walletId, assetId: assetId)
                try assetsService.updateEnabled(walletId: walletId, assetId: assetId, enabled: enabled)
            }
            if enabled {
                Task {
                    try await updateBalance(for: walletId, assetIds: assets)
                }
                Task {
                    try await updatePrices(assetIds: assets)
                }
            }
        } catch {
            NSLog("enableAssetId: \(error)")
        }
    }
    
    func hideAsset(walletId: WalletId, assetId: AssetId) throws {
        try balanceService.hideAsset(walletId: walletId, assetId: assetId)
    }
    
    // transactions
    
    func addTransaction(walletId: String, transaction: Primitives.Transaction) throws {
        try transactionService.addTransaction(walletId: walletId, transaction: transaction)
    }

    func setupWallet(_ wallet: Wallet) throws {
        let chains = wallet.chains(type: .all)
        try enableAssetBalances(wallet: wallet, chains: chains)
    }

    func enableAssetBalances(wallet: Wallet, chains: [Chain]) throws {
        try addAssetsBalancesIfMissing(assetIds: chains.ids, wallet: wallet)
    }
    
    // In the future move into separate service
    func runAddressStatusCheck(_ wallet: Wallet) async {
        guard !wallet.preferences.completeInitialAddressStatus else { return }
    
        do {
            let results = try await addressStatusService.getAddressStatus(accounts: wallet.accounts)
            
            for (account, statuses) in results {
                if statuses.contains(.multiSignature) {
                    try bannerSetupService.setupAccountMultiSignatureWallet(walletId: wallet.walletId, chain: account.chain)
                }
            }
            wallet.preferences.completeInitialAddressStatus = true
        } catch {
            NSLog("runAddressStatusCheck: \(error)")
        }
    }
}

extension Wallet {
    var preferences: WalletPreferencesStore {
        return WalletPreferencesStore(walletId: id)
    }
}
