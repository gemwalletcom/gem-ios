import Foundation
import AppService
import Primitives
import Keystore
import Components
import Store
import BigInt
import WalletConnectorService
import GemstonePrimitives
import Blockchain
import Localization
import DeviceService
import PriceAlertService
import GemAPI
import Transfer
import ChainService
import BannerService
import StakeService
import NotificationService
import NodeService
import PriceService
import WalletConnector
import Preferences
import NFTService
import BalanceService
import AssetsService
import TransactionsService
import TransactionService
import DiscoverAssetsService
import WalletsService
import WalletService
import AvatarService
import ScanService
import WalletSessionService

extension Asset {
    static let main = Asset.bitcoin
    static let ethereum = Asset(id: Chain.ethereum.assetId, name: "Ethereum", symbol: "ETH", decimals: 18, type: .native)
    static let bitcoin = Asset(id: Chain.bitcoin.assetId, name: "Bitcoin", symbol: "BTC", decimals: 8, type: .native)
    static let cosmos = Asset(id: Chain.cosmos.assetId, name: "Cosmos", symbol: "Atom", decimals: 8, type: .native)
}

extension Balance {
    static let main = Balance(available: "10")
}

extension Price {
    static let main = Price(price: 10, priceChangePercentage24h: 21, updatedAt: .now)
}

extension LocalKeystore {
    static let main = LocalKeystore()
}

extension WalletStore {
    static let main = WalletStore(db: .main)
}

extension BannerStore {
    static let main = BannerStore(db: .main)
}

extension AssetsService {
    static let main = AssetsService(
        assetStore: .main,
        balanceStore: .main,
        chainServiceFactory: .main
    )
}

extension NotificationHandler {
    static let main = NotificationHandler()
}

extension BalanceService {
    static let main = BalanceService(
        balanceStore: .main,
        assertStore: .main,
        chainServiceFactory: .main
    )
}

extension StakeService {
    static let main = StakeService(
        store: .main,
        chainServiceFactory: .main
    )
}

extension PriceService {
    static let main = PriceService(priceStore: .main, fiatRateStore: .main)
}

extension PriceObserverService {
    static let main = PriceObserverService(priceService: .main, preferences: .standard)
}

extension TransactionService {
    static let main = TransactionService(
        transactionStore: .main,
        stakeService: .main,
        nftService: .main,
        chainServiceFactory: .main,
        balanceUpdater: BalanceService.main
    )
}

extension NodeService {
    static let main = NodeService(nodeStore: .main)
}

extension ScanService {
    static let main = ScanService(securePreferences: .standard)
}

extension WalletsService {
    static let main = WalletsService(
        walletStore: .main,
        assetsService: .main,
        balanceService: .main,
        priceService: .main,
        priceObserver: .main,
        chainService: .main,
        transactionService: .main,
        bannerSetupService: .main,
        addressStatusService: .main
    )
}

extension PriceAlertService {
    static let main = PriceAlertService(store: .main, deviceService: DeviceService.main, priceObserverService: .main)
}

extension TransactionsService {
    static let main = TransactionsService(
        transactionStore: .main,
        assetsService: .main,
        walletStore: .main
    )
}

extension DeviceService {
    static let main = DeviceService(deviceProvider: GemAPIService.shared, subscriptionsService: .main)
}

extension WalletService {
    static let main = WalletService(
        keystore: LocalKeystore.main,
        walletStore: .main,
        preferences: .default,
        avatarService: .main
    )
}

extension AssetStore {
    static let main = AssetStore(db: .main)
}

extension PriceStore {
    static let main = PriceStore(db: .main)
}

extension FiatRateStore {
    static let main = FiatRateStore(db: .main)
}

extension PriceAlertStore {
    static let main = PriceAlertStore(db: .main)
}

extension BalanceStore {
    static let main = BalanceStore(db: .main)
}

extension TransactionStore {
    static let main = TransactionStore(db: .main)
}

extension NodeStore {
    static let main = NodeStore(db: .main)
}

extension StakeStore {
    static let main = StakeStore(db: .main)
}

extension ConnectionsStore {
    static let main = ConnectionsStore(db: .main)
}

extension SubscriptionService {
    static let main = SubscriptionService(subscriptionProvider: GemAPIService.shared, walletStore: .main)
}

extension ConnectionsService {
    static let main = ConnectionsService(store: .main, signer: WalletConnectorSigner.main)
}

extension AddressStatusService {
    static let main = AddressStatusService(chainServiceFactory: .main)
}

extension BannerSetupService {
    static let main = BannerSetupService(store: .main)
}

extension NFTService {
    static let main = NFTService(nftStore: .main)
}

extension NFTStore {
    static let main = NFTStore(db: .main)
}

extension AvatarService {
    static let main = AvatarService(store: .main)
}

extension AppReleaseService {
    static let main = AppReleaseService()
}

extension WalletConnectorSigner {
    static let main = WalletConnectorSigner(
        connectionsStore: .main,
        walletSessionService: WalletSessionService(walletStore: .main, preferences: .default),
        walletConnectorInteractor: WalletConnectorManager(presenter: WalletConnectorPresenter())
    )
}
 
extension DB {
    static let main = DB(fileName: "db.sqlite")
}

extension Wallet {
    static let main = Wallet(id: "1", name: "Test", index: 0, type: .multicoin, accounts: [.main], order: 0, isPinned: false, imageUrl: nil)
    static let view = Wallet(id: "1", name: "Test", index: 0, type: .view, accounts: [.main], order: 0, isPinned: false, imageUrl: nil)
}

extension WalletId {
    static let main = Wallet.main.walletId
}

extension Account {
    static let main = Account(
        chain: .bitcoin,
        address: "btc123123",
        derivationPath: "",
        extendedPublicKey: .none
    )
}

extension Recipient {
    static let main = Recipient(name: "", address: "", memo: .none)
}

extension RecipientData {
    static let main = RecipientData(recipient: .main, amount: .none)
}

extension TransferData {
    static let main = TransferData(type: .transfer(.main), recipientData: .main, value: .zero, canChangeValue: true)
}

extension Wallet {
    func account(for chain: Chain) throws -> Account {
        guard let account = accounts.filter({ $0.chain == chain }).first else {
            throw AnyError("account not found for chain: \(chain.rawValue)")
        }
        return account
    }
}

extension BigNumberFormatter {
    static let full: BigNumberFormatter = BigNumberFormatter()
    static let medium: BigNumberFormatter = BigNumberFormatter(maximumFractionDigits: 6)
    static let short: BigNumberFormatter = BigNumberFormatter(maximumFractionDigits: 2)
    static let simple: BigNumberFormatter = BigNumberFormatter(groupingSeparator: "")
}

extension CurrencyFormatter {
    static func currency() -> CurrencyFormatter {
        return CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)
    }
    
    static func percent() -> CurrencyFormatter {
        return CurrencyFormatter(type: .percent, currencyCode: Preferences.standard.currency)
    }
}

extension ChainCoreError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cantEstimateFee, .feeRateMissed: Localized.Errors.unableEstimateNetworkFee
        case .incorrectAmount: Localized.Errors.invalidAmount
        case .dustThreshold(let chain): Localized.Errors.dustThreshold(chain.asset.name)
        }
    }
}

extension ChainServiceFactory {
    static let main = ChainServiceFactory(nodeProvider: NodeService.main)
}

extension BannerService {
    static let main = BannerService(store: .main, pushNotificationService: PushNotificationEnablerService())
}

extension NavigationStateManager {
    static let main = NavigationStateManager()
}
