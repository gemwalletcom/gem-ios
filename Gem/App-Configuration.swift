import Foundation
import Settings
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
    static let main = Price(price: 10, priceChangePercentage24h: 21)
}

extension PriceAlert {
    static let main = PriceAlert(assetId: AssetId.main.identifier, price: .none, pricePercentChange: .none, priceDirection: .none)
}

extension AssetMetaData {
    static let main = AssetMetaData(
        isEnabled: true,
        isBuyEnabled: true,
        isSellEnabled: true,
        isSwapEnabled: true,
        isStakeEnabled: false,
        isPinned: false,
        isActive: true,
        stakingApr: .none
    )
}

extension AssetId {
    static let main = Self.ethereum
    static let ethereum = Chain.ethereum.assetId
    static let bitcoin = Chain.bitcoin.assetId
    static let smartChain = Chain.smartChain.assetId
}

extension AssetData  {
    static let main = AssetData(
        asset: .main,
        balance: .main,
        account: .main,
        price: .main,
        price_alert: .none,
        metadata: .main
    )
}

extension LocalKeystore {
    @MainActor static let main = LocalKeystore(folder: "keystore", walletStore: .main, preferences: .standard)
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

extension NotificationService {
    static let main = NotificationService()
}

extension BalanceService {
    static let main = BalanceService(
        balanceStore: .main,
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
    static let main = PriceService(priceStore: .main)
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

extension DiscoverAssetsService {
    static let main = DiscoverAssetsService(
        balanceService: .main,
        chainServiceFactory: .main
    )
}

extension NodeService {
    static let main = NodeService(nodeStore: .main)
}

extension WalletsService {
    static let main = WalletsService(
        keystore: LocalKeystore.main,
        priceStore: .main,
        assetsService: .main,
        balanceService: .main,
        priceService: .main,
        discoverAssetService: .main,
        transactionService: .main,
        bannerSetupService: .main,
        addressStatusService: .main
    )
}

extension PriceAlertService {
    static let main = PriceAlertService(store: .main, deviceService: DeviceService.main)
}

extension TransactionsService {
    static let main = TransactionsService(transactionStore: .main, assetsService: .main, keystore: LocalKeystore.main)
}

extension DeviceService {
    static let main = DeviceService(deviceProvider: GemAPIService.shared, subscriptionsService: .main)
}

extension WalletService {
    static let main = WalletService(keystore: LocalKeystore.main, walletStore: .main)
}

extension AssetStore {
    static let main = AssetStore(db: .main)
}

extension PriceStore {
    static let main = PriceStore(db: .main)
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

extension WalletConnectorSigner {
    static let main = WalletConnectorSigner(
        store: .main,
        keystore: LocalKeystore.main,
        walletConnectorInteractor: WalletConnectorManager(presenter: WalletConnectorPresenter())
    )
}
 
extension DB {
    static let main = DB(path: "db.sqlite")
}

extension Wallet {
    static let main = Wallet(id: "1", name: "Test", index: 0, type: .multicoin, accounts: [.main], order: 0, isPinned: false)
    static let view = Wallet(id: "1", name: "Test", index: 0, type: .view, accounts: [.main], order: 0, isPinned: false)
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

extension Transaction {
    static let main = Transaction(
        id: "chain_1",
        hash: "1",
        assetId: .main,
        from: "address-1",
        to: "address-2",
        contract: .none,
        type: .transfer,
        state: .confirmed,
        blockNumber: 1.asString,
        sequence: 1.asString,
        fee: BigInt(1).description,
        feeAssetId: .main,
        value: BigInt(1).description,
        memo: "",
        direction: .outgoing,
        utxoInputs: [],
        utxoOutputs: [],
        metadata: .null,
        createdAt: .now
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

extension TransferDataMetadata {
    static let main = TransferDataMetadata(assetBalance: .zero, assetFeeBalance: .zero, assetPrice: .none, feePrice: .none, assetPrices: [:])
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
    static let main = NavigationStateManager(initialSelecedTab: .wallet)
}
