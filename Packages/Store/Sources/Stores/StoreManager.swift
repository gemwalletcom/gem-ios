// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct StoreManager: Sendable {
    public let assetStore: AssetStore
    public let balanceStore: BalanceStore
    public let fiatRateStore: FiatRateStore
    public let priceStore: PriceStore
    public let transactionStore: TransactionStore
    public let nodeStore: NodeStore
    public let walletStore: WalletStore
    public let connectionsStore: ConnectionsStore
    public let stakeStore: StakeStore
    public let bannerStore: BannerStore
    public let priceAlertStore: PriceAlertStore
    public let nftStore: NFTStore
    public let addressStore: AddressStore
    public let perpetualStore: PerpetualStore
    public let recentActivityStore: RecentActivityStore
    public let inAppNotificationStore: InAppNotificationStore

    public init(db: DB) {
        self.assetStore = AssetStore(db: db)
        self.balanceStore = BalanceStore(db: db)
        self.fiatRateStore = FiatRateStore(db: db)
        self.priceStore = PriceStore(db: db)
        self.transactionStore = TransactionStore(db: db)
        self.nodeStore = NodeStore(db: db)
        self.walletStore = WalletStore(db: db)
        self.connectionsStore = ConnectionsStore(db: db)
        self.stakeStore = StakeStore(db: db)
        self.bannerStore = BannerStore(db: db)
        self.priceAlertStore = PriceAlertStore(db: db)
        self.nftStore = NFTStore(db: db)
        self.addressStore = AddressStore(db: db)
        self.perpetualStore = PerpetualStore(db: db)
        self.recentActivityStore = RecentActivityStore(db: db)
        self.inAppNotificationStore = InAppNotificationStore(db: db)
    }
}
