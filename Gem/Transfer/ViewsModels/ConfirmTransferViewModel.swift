import Foundation
import Keystore
import Primitives
import Blockchain
import BigInt
import Components
import Signer
import Style
import GemstonePrimitives

class ConfirmTransferViewModel: ObservableObject {
    @Published var state: StateViewType<TransactionInputViewModel> = .loading

    let data: TransferData
    private var metadata: TransferDataMetadata?

    private let wallet: Wallet
    private let keystore: any Keystore
    private let service: ChainServiceable

    private let walletService: WalletService
    private let confirmTransferDelegate: ConfirmTransferDelegate?
    
    init(
        wallet: Wallet,
        keystore: any Keystore,
        data: TransferData,
        service: ChainServiceable,
        walletService: WalletService,
        confirmTransferDelegate: ConfirmTransferDelegate? = .none
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.data = data
        self.service = service
        self.walletService = walletService
        self.confirmTransferDelegate = confirmTransferDelegate

        // prefetch asset metadata from local storage
        let metadata = try? getAssetMetaData(walletId: wallet.id, asset: data.recipientData.asset, assetsIds: data.type.assetIds)
        self.metadata = metadata
    }
    
    var title: String {
        switch data.type {
        case .transfer: Localized.Transfer.Send.title
        case .swap(_, _, let type):
            switch type {
            case .approval: Localized.Transfer.Approve.title
            case .swap: Localized.Wallet.swap
            }
        case .generic: Localized.Transfer.Approve.title
        case .stake(_, let type):
            switch type {
            case .stake: Localized.Transfer.Stake.title
            case .unstake: Localized.Transfer.Unstake.title
            case .redelegate: Localized.Transfer.Redelegate.title
            case .rewards: Localized.Transfer.ClaimRewards.title
            case .withdraw: Localized.Transfer.Withdraw.title
            }
        }
    }

    var appTitle: String { Localized.WalletConnect.app }
    var appValue: String? {
        switch data.type {
        case .transfer,
            .swap,
            .stake: .none
        case .generic(_, let metadata, _):
            metadata.name
        }
    }

    var websiteURL: URL? {
        switch data.type {
        case .transfer,
            .swap,
            .stake: .none
        case .generic(_, let metadata, _):
            URL(string: metadata.url)
        }
    }
    var websiteTitle: String { Localized.WalletConnect.website }
    var websiteValue: String? {
        guard let url = websiteURL, let host = url.host(percentEncoded: true) else {
            return .none
        }
        return host
    }

    var senderTitle: String { Localized.Transfer.from }
    var senderValue: String { wallet.name }
    var senderAddress: String {
        return try! wallet.account(for: data.recipientData.asset.chain).address
    }
    var senderAddressExplorerUrl: URL { senderLink.url }
    var senderExplorerText: String { Localized.Transaction.viewOn(senderLink.url) }

    var recipientTitle: String {
        switch data.type {
        case .swap(_, _, _):
            Localized.Swap.provider
        case .stake:
            Localized.Stake.validator
        default:
            Localized.Transfer.to
        }
    }
    var recipientValue: SimpleAccount {
        if let value = state.value {
            return value.recipientAccount
        }
        let simpleAccount = SimpleAccount(name: data.recipientData.recipient.name,
                                          chain: data.recipientData.asset.chain,
                                          address: data.recipientData.recipient.address)
        return simpleAccount
    }

    var shouldShowRecipientField: Bool {
        switch data.type {
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .unstake, .redelegate, .withdraw: true
            case .rewards: false
            }
        default: true
        }
    }

    var networkTitle: String { Localized.Transfer.network }
    var networkValue: String {
        if let value = state.value {
            return value.network
        }
        return data.recipientData.asset.chain.asset.name
    }
    var networkAssetImage: AssetImage {
        return AssetIdViewModel(assetId: data.recipientData.asset.chain.assetId).assetImage
    }

    var networkFeeTitle: String { Localized.Transfer.networkFee }
    var networkFeeValue: String? {
        if state.isError {
            return "-"
        }
        return state.value?.networkFeeText
    }
    var networkFeeFiatValue: String? {
        if state.isError {
            return nil
        }
        return state.value?.networkFeeFiatText
    }

    var buttonTitle: String {
        // try again on failed data load
        if state.isError {
            return Localized.Common.tryAgain
        }
        
        // error message on success data load and calucalor
        if let result = state.value?.transferAmountResult,
           case .error(_, let transferAmountCalculatorError) = result {

            let title: String = {
                switch transferAmountCalculatorError {
                case .insufficientBalance(let asset):
                    return Localized.Transfer.insufficientBalance(AssetViewModel(asset: asset).title)
                case .insufficientNetworkFee(let asset):
                    return Localized.Transfer.insufficientNetworkFeeBalance(AssetViewModel(asset: asset).title)
                }
            }()

            return title
        }

        // confirm on success data load
        return Localized.Transfer.confirm
    }

    var buttonImage: String? {
        if state.isError {
            return nil
        }

        if let result = state.value?.transferAmountResult, case .error = result {
            return nil
        }

        let type = (try? keystore.getPasswordAuthentication()) ?? .none
        switch type {
        case .biometrics: return SystemImage.faceid
        case .passcode: return SystemImage.lock
        case .none: return SystemImage.none
        }
    }

    var shouldDisalbeButton: Bool {
        if let result = state.value?.transferAmountResult, case .error = result {
            return true
        }
        return state.isNoData
    }

    var shouldShowMemo: Bool {
        if let value = state.value {
            return value.showMemoField
        }

        switch data.type {
        case .transfer:
            return AssetViewModel(asset: data.recipientData.asset).supportMemo
        case .swap, .generic, .stake:
            return false
        }
    }

    var memo: String? {
        state.value?.memo ?? data.recipientData.recipient.memo
    }

    var dismissAmount: Int {
        switch data.type {
        case .swap(_, _, let type):
            switch type {
            case .swap: 2
            case .approval: 1
            }
        default: 2
        }
    }

    var broadcastOptions: BroadcastOptions {
        switch data.recipientData.asset.chain {
        case .solana:
            switch data.type {
            case .transfer, .stake:
                return .standard
            case .swap, .generic:
                return BroadcastOptions(skipPreflight: true)
            }
        default:
            return .standard
        }
    }

    var headerType: TransactionHeaderType {
        if let value = state.value {
            return value.headerType
        }
        return TransactionInputViewModel(data: data, input: nil, metaData: metadata, transferAmountResult: nil).headerType
    }
}

// MARK: - Business Logic

extension ConfirmTransferViewModel {
    func fetch() async {
        await MainActor.run { [self] in
            self.state = .loading
        }

        let asset = data.recipientData.asset
        let destinationAddress = data.recipientData.recipient.address
        let value = data.value
        let recipientMemo = data.recipientData.recipient.memo
        let memo = recipientMemo == .empty ? .none : recipientMemo

        do {
            let senderAddress = try wallet.account(for: asset.chain).address
            let metaData = try getAssetMetaData(walletId: wallet.id, asset: asset, assetsIds: data.type.assetIds)
            let transactionInput = TransactionInput(
                type: data.type,
                asset: asset,
                senderAddress: senderAddress,
                destinationAddress: destinationAddress,
                value: value,
                balance: metaData.assetBalance,
                memo: memo
            )

            let preloadInput = try await service.load(input: transactionInput)
            let fee = preloadInput.fee.totalFee
            let transferAmountResult = TransferAmountCalculator().calculateResult(
                input: TranferAmountInput(
                    asset: asset,
                    assetBalance: Balance(available: metaData.assetBalance),
                    value: value,
                    availableValue: availableValue,
                    assetFee: asset.feeAsset,
                    assetFeeBalance: Balance(available: metaData.assetFeeBalance),
                    fee: fee
                )
            )
            let transactionInputModel = TransactionInputViewModel(
                data: data,
                input: preloadInput,
                metaData: metaData,
                transferAmountResult: transferAmountResult
            )

            await MainActor.run { [self] in
                self.state = .loaded(transactionInputModel)
            }
        } catch {
            await MainActor.run { [self] in
                self.state = .error(error)
            }
            NSLog("preload transaction error: \(error)")
        }
    }

    func sign(transferData: TransferData, input: TransactionPreload, amount: TranferAmount) async throws -> String  {
        let signer = Signer(wallet: wallet, keystore: keystore)

        let senderAddress = try wallet.account(for: transferData.recipientData.asset.chain).address
        let destinationAddress = transferData.recipientData.recipient.address
        let isMaxAmount = amount.useMaxAmount

        let input = SignerInput(
            type: transferData.type,
            asset: transferData.recipientData.asset,
            value: amount.value,
            fee: Fee(
                fee: amount.networkFee,
                gasPriceType: input.fee.gasPriceType,
                gasLimit: input.fee.gasLimit,
                options: input.fee.options
            ),
            isMaxAmount: isMaxAmount,
            chainId: input.chainId,
            memo: transferData.recipientData.recipient.memo,
            accountNumber: input.accountNumber,
            sequence: input.sequence,
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            block: input.block,
            token: input.token,
            utxos: input.utxos,
            messageBytes: input.messageBytes,
            extra: input.extra
        )
        return try signer.sign(input: input)
    }

    func broadcast(data: String, options: BroadcastOptions) async throws -> String  {
        NSLog("broadcast data \(data)")
        let hash = try await service.broadcast(data: data, options: options)
        NSLog("broadcast response \(hash)")
        confirmTransferDelegate?(.success(hash))

        return hash
    }

    func addTransaction(transaction: Transaction) throws {
        NSLog("transaction \(transaction)")
        try walletService.addTransaction(walletId: wallet.id, transaction: transaction)
    }

    func getTransaction(
        input: TransactionPreload,
        amount: TranferAmount,
        hash: String
    ) throws -> Primitives.Transaction {
        let senderAddress = try wallet.account(for: data.recipientData.asset.chain).address
        let direction: TransactionDirection = {
            if data.recipientData.recipient.address == senderAddress {
                return .selfTransfer
            }
            return .outgoing
        }()
        return Transaction(
            id: Transaction.id(chain: data.recipientData.asset.chain.rawValue, hash: hash),
            hash: hash,
            assetId: data.recipientData.asset.id,
            from: try wallet.account(for: data.recipientData.asset.chain).address,
            to: data.recipientData.recipient.address,
            contract: .none,
            type: data.type.transactionType,
            state: .pending,
            blockNumber: 0.asString,
            sequence: input.sequence.asString,
            fee: amount.networkFee.description,
            feeAssetId: data.recipientData.asset.feeAsset.id,
            value: amount.value.description,
            memo: data.recipientData.recipient.memo ?? "",
            direction: direction,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: data.type.metadata,
            createdAt: Date()
        )
    }
}

// MARK: - Private

extension ConfirmTransferViewModel {
    private var senderLink: BlockExplorerLink {
        ExplorerService.main.addressUrl(chain: data.recipientData.asset.chain, address: senderAddress)
    }

    private var availableValue: BigInt {
        switch data.type {
        case .transfer(let asset), .swap(let asset, _, _), .generic(let asset, _, _):
            guard let balance = try? walletService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
            return balance.available
        case .stake(let asset, let stakeType):
            switch stakeType {
            case .stake:
                guard let balance = try? walletService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
                return balance.available
            case .unstake(let delegation):
                return delegation.base.balanceValue
            case .redelegate(let delegation, _):
                return delegation.base.balanceValue
            case .rewards:
                return data.value
            case .withdraw(let delegation):
                return delegation.base.balanceValue
            }
        }
    }

    private func getAssetMetaData(walletId: String, asset: Asset, assetsIds: [AssetId]) throws -> TransferDataMetadata {
        let assetId = asset.id
        let feeAssetId = asset.feeAsset.id
        let assetBalance = try walletService.balanceService.getBalance(walletId: walletId, assetId: assetId.identifier)!
        let assetFeeBalance = try walletService.balanceService.getBalance(walletId: walletId, assetId: feeAssetId.identifier)!
        let assetPricesIds: [AssetId] = [assetId, feeAssetId] + assetsIds.map { $0 }
        let assetPrices = try walletService.priceService.getPrices(for: assetPricesIds).toMap { AssetId(id: $0.assetId)! }

        let assetPricesMap = assetPrices.reduce(into: [:]) { partialResult, value in
            partialResult[value.key.identifier] = Price(price: value.value.price, priceChangePercentage24h: value.value.priceChangePercentage24h)
        }

        return TransferDataMetadata(
            assetBalance: assetBalance.available,
            assetFeeBalance: assetFeeBalance.available,
            assetPrice: assetPrices[assetId]?.mapToPrice(),
            feePrice: assetPrices[feeAssetId]?.mapToPrice(),
            assetPrices: assetPricesMap
        )
    }
}
