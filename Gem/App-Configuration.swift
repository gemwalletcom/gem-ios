import Foundation
import Settings
import Primitives
import Keystore
import Components
import Store
import BigInt
import WalletConnector
import GemstoneSwift

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

extension AssetMetaData {
    static let main = AssetMetaData(isEnabled: true, isBuyEnabled: true, isSwapEnabled: true, isStakeEnabled: false)
}

extension AssetId {
    static let main = Self.ethereum
    static let ethereum = AssetId(id: "ethereum")!
    static let bitcoin = AssetId(id: "bitcoin")!
    static let binance = AssetId(id: "binance")!
}

extension AssetData  {
    static let main = AssetData(asset: .main, balance: .main, account: .main, price: .main, details: .none, metadata: .main)
}

extension Preferences {
    static let main = Preferences(defaults: .standard)
}

extension LocalKeystore {
    static let main = LocalKeystore(folder: "keystore", walletStore: .main, preferences: .main)
}

extension WalletStore {
    static let main = WalletStore(db: .main)
}

extension AssetsService {
    static let main = AssetsService(
        assetStore: .main,
        balanceStore: .main, 
        chainServiceFactory: .init(nodeProvider: NodeService.main)
    )
}

extension ChartService {
    static let main = ChartService()
}

extension BalanceService {
    static let main = BalanceService(
        balanceStore: .main,
        chainServiceFactory: .init(nodeProvider: NodeService.main)
    )
}

extension StakeService {
    static let main = StakeService(
        store: .main,
        chainServiceFactory: .init(nodeProvider: NodeService.main)
    )
}

extension PriceService {
    static let main = PriceService(priceStore: .main)
}

extension TransactionService {
    static let main = TransactionService(
        transactionStore: .main,
        stakeService: .main,
        chainServiceFactory: .init(nodeProvider: NodeService.main),
        balanceUpdater: BalanceService.main
    )
}

extension DiscoverAssetsService {
    static let main = DiscoverAssetsService(
        balanceService: .main,
        chainServiceFactory: .init(nodeProvider: NodeService.main)
    )
}

extension NodeService {
    static let main = NodeService(nodeStore: .main)
}

extension NameService {
    static let main = NameService()
}

extension WalletService {
    static let main = WalletService(
        priceStore: .main,
        assetsService: .main,
        balanceService: .main,
        stakeService: .main,
        priceService: .main,
        discoverAssetService: .main,
        transactionService: .main,
        nodeService: NodeService.main,
        connectionsService: ConnectionsService.main
    )
}

extension TransactionsService {
    static let main = TransactionsService(transactionStore: .main, assetsService: .main)
}

extension AssetStore {
    static let main = AssetStore(db: .main)
}

extension PriceStore {
    static let main = PriceStore(db: .main)
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
    static let main = SubscriptionService(walletStore: .main)
}

extension WalletConnector {
    static let main = WalletConnector(signer: WalletConnectorSigner.main)
}

extension ConnectionsService {
    static let main = ConnectionsService(store: .main, signer: WalletConnectorSigner.main)
}

extension WalletConnectorSigner {
    static let main = WalletConnectorSigner(store: .main, keystore: LocalKeystore.main, walletConnectorInteractor: WalletConnectorInteractor.main)
}

extension WalletConnectorInteractor {
    static let main = WalletConnectorInteractor()
}
 
extension DB {
    static let main = DB(path: "db.sqlite")
}

extension Wallet {
    static let main = Wallet(id: "1", name: "Test", index: 0, type: .multicoin, accounts: [.main])
    static let view = Wallet(id: "1", name: "Test", index: 0, type: .view, accounts: [.main])
}

extension Account {
    static let main = Account(chain: .bitcoin, address: "btc123123", derivationPath: "", extendedPublicKey: "")
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

extension AssetListView {
    static func make(assetData: AssetData, formatter: ValueFormatter) -> AssetListView {
        return AssetListView(
            model: AssetListViewModel(
                assetDataModel: AssetDataViewModel(assetData: assetData, formatter: formatter)
            )
        )
    }
}
extension Recipient {
    static let main = Recipient(name: "", address: "", memo: .none)
}

extension RecipientData {
    static let main = RecipientData(asset: .main, recipient: .main)
}

extension TransferData {
    static let main = TransferData(type: .transfer(.main), recipientData: .main, value: .zero)
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
    static let full: BigNumberFormatter = {
        let formatter = BigNumberFormatter()
        return formatter
    }()
    static let medium: BigNumberFormatter = {
        let formatter = BigNumberFormatter()
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    static let short: BigNumberFormatter = {
        let formatter = BigNumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    // no group separator
    static let simple: BigNumberFormatter = {
        let formatter = BigNumberFormatter()
        formatter.groupingSeparator = ""
        return formatter
    }()
}

extension ValueFormatter {
    static let short = ValueFormatter(style: .short)
    static let medium = ValueFormatter(style: .medium)
    static let full = ValueFormatter(style: .full)
}

extension CurrencyFormatter {
    static func currency() -> CurrencyFormatter {
        return CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)
    }
    
    static func percent() -> CurrencyFormatter {
        return CurrencyFormatter(type: .percent, currencyCode: Preferences.standard.currency)
    }
}
