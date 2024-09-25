import Foundation
import Blockchain
import Primitives
import Store
import GemAPI
import Combine
import Settings
import Keystore

class WalletsService {
    
    let keystore: any Keystore
    let assetsService: AssetsService
    let balanceService: BalanceService
    let stakeService: StakeService
    let priceService: PriceService
    
    private let connectionsService: ConnectionsService
    private let discoverAssetService: DiscoverAssetsService
    private let transactionService: TransactionService
    private let nodeService: NodeService

    private var assetObserver: AnyCancellable?
    private var balanceObserver: AnyCancellable?
    private var balanceErrorsObserver: AnyCancellable?
    
    init(
        keystore: any Keystore,
        priceStore: PriceStore,
        assetsService: AssetsService,
        balanceService: BalanceService,
        stakeService: StakeService,
        priceService: PriceService,
        discoverAssetService: DiscoverAssetsService,
        transactionService: TransactionService,
        nodeService: NodeService,
        connectionsService: ConnectionsService
    ) {
        self.keystore = keystore
        self.assetsService = assetsService
        self.balanceService = balanceService
        self.stakeService = stakeService
        self.priceService = priceService
        self.discoverAssetService = discoverAssetService
        self.transactionService = transactionService
        self.nodeService = nodeService
        self.connectionsService = connectionsService

        defer {
            self.balanceObserver = balanceService.observeBalance().sink { update in
                for balance in update.balances {
                    NSLog("observe balance: \(balance.assetId.identifier): \(balance.balance.available)")
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
        let prices = try priceService.getPrices(for: assetIds)

        let updateBalances = balanceService.createBalanceUpdate(
            assets: assets,
            balances: update.balances,
            prices: prices
        )
        
        try? balanceService.updateBalances(updateBalances, walletId: update.walletId)
    }
    
    func updatePrices() async throws {
        let assetIds = try assetsService.getEnabledAssets()
        try await updatePrices(assetIds: assetIds)
    }
    
    func updatePrices(assetIds: [AssetId]) async throws {
        NSLog("fetch prices. assetIds: \(assetIds.count)")
        
        let prices = try await priceService.fetchPrices(for: assetIds.ids)
        try priceService.updatePrices(prices: prices)
        try balanceService
            .getWalletBalances(assetIds: assetIds.ids)
            .toMapArray { $0.walletId }
            .forEach {
                try storeBalances(update: BalanceUpdate(walletId: $0.key, balances: $0.value.map { $0.balance }))
            }
    }
    
    // add asset to asset store and create balance store record
    func addAssetsBalancesIfMissing(assetIds: [AssetId], wallet: Wallet) throws {
        try balanceService.addAssetsBalancesIfMissing(assetIds: assetIds, wallet: wallet)
    }
    
    func getNewAssets(for wallet: Wallet) async throws {
        //FIXME: temp solution to wait for 1 second (need to wait until subscriptions updated)
        //otherwise it would return no assets
        try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
        
        let preferences = wallet.preferences
        let deviceId = try SecurePreferences.standard.getDeviceId()
        let newTimestamp = Int(Date.now.timeIntervalSince1970)
        
        try await discoverAssetService.updateTokens(
            deviceId: deviceId,
            wallet: wallet,
            fromTimestamp: preferences.assetsTimestamp
        )
        preferences.assetsTimestamp = newTimestamp
        
        if !preferences.completeInitialLoadAssets {
            await discoverAssetService.updateCoins(wallet: wallet)
            preferences.completeInitialLoadAssets = true
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
    
    func updatePendingTransactions() async throws  {
        try await transactionService.updatePendingTransactions()
    }
    
    // nodes
    
    func updateNode(chain: Chain) throws {
        try nodeService.update(chain: chain)
    }

    //

    func setupWallet(_ wallet: Wallet) throws {
        let chains = wallet.chains(type: .all)
        try enableAssetBalances(wallet: wallet, chains: chains)
    }

    func enableAssetBalances(wallet: Wallet, chains: [Chain]) throws {
        try addAssetsBalancesIfMissing(assetIds: chains.ids, wallet: wallet)
    }
}

extension Wallet {
    var preferences: WalletPreferencesStore {
        return WalletPreferencesStore(walletId: id)
    }
}
