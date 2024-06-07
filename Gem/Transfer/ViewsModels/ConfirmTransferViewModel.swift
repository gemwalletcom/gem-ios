import Foundation
import Keystore
import Primitives
import Blockchain
import BigInt
import Components
import Signer
import GemstoneSwift
import Style

class ConfirmTransferViewModel: ObservableObject {
    
    @Published var state: StateViewType<TransactionInputViewModel> = .loading
    
    let wallet: Wallet
    let keystore: any Keystore
    let data: TransferData
    let service: ChainServiceable
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
    var senderField: String { Localized.Transfer.from }
    
    var showRecipientField: Bool {
        switch data.type {
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake, .unstake, .redelegate, .withdraw: true
            case .rewards: false
            }
        default: true
        }
    }
    
    var recipientField: String {
        switch data.type {
        case .swap(_, _, _):
            Localized.Swap.provider
        case .stake:
            Localized.Stake.validator
        default:
            Localized.Transfer.to
        }
    }
    var networkField: String { Localized.Transfer.network }
    var networkFeeField: String { Localized.Transfer.networkFee }
    var networkAssetImage: AssetImage {
        return AssetIdViewModel(assetId: data.recipientData.asset.chain.assetId).assetImage
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
    
    var appText: String? {
        switch data.type {
        case .transfer,
            .swap,
            .stake: .none
        case .generic(_, let metadata, _):
            metadata.name
        }
    }
    
    var website: URL? {
        switch data.type {
        case .transfer,
            .swap,
            .stake: .none
        case .generic(_, let metadata, _):
            URL(string: metadata.url)
        }
    }
    
    var websiteText: String? {
        guard let url = website, let host = url.host(percentEncoded: true) else {
            return .none
        }
        return host
    }
    
    var buttonTitle: String { Localized.Transfer.confirm }
    var buttonImage: String {
        let type = (try? keystore.getPasswordAuthentication()) ?? KeystoreAuthentication.none
        switch type {
        case .biometrics:
            return SystemImage.faceid
        case .passcode:
            return SystemImage.lock
        case .none:
            return SystemImage.none
        }
    }
    
    var senderText: String {
        return wallet.name
    }
    
    var senderAddress: String {
        return try! wallet.account(for: data.recipientData.asset.chain).address
    }
    
    var senderAddressExplorerUrl: URL {
        return ExplorerService.addressUrl(chain: data.recipientData.asset.chain, address: senderAddress)
    }
    
    var senderExplorerText: String {
        return Localized.Transaction.viewOn(ExplorerService.hostName(url: senderAddressExplorerUrl))
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
            messageBytes: input.messageBytes
        )
        return try signer.sign(input: input)
    }
    
    func broadcast(data: String, options: BroadcastOptions) async throws -> String  {
        NSLog("broadcast data \(data)")
        
        let hash = try await service.broadcast(data: data, options: options)
        
        confirmTransferDelegate?(.success(hash))
    
        NSLog("broadcast response \(hash)")
        return hash
    }

    var availableValue: BigInt {
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
    
    func getAssetMetaData(walletId: String, asset: Asset, assetsIds: [AssetId]) throws -> TransferDataMetadata {
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
    
    func fetch() async throws {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        let asset = data.recipientData.asset
        let senderAddress = try wallet.account(for: asset.chain).address
        let destinationAddress = data.recipientData.recipient.address
        let value = data.value
        let recipientMemo = data.recipientData.recipient.memo
        let memo = recipientMemo == .empty ? .none : recipientMemo
        
        do {
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
                input: preloadInput,
                data: data,
                metaData: metaData,
                transferAmountResult: transferAmountResult
            )
            
            DispatchQueue.main.async {
                self.state = .loaded(transactionInputModel)
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(error)
            }
            NSLog("preload transaction error: \(error)")
        }
    }
    
    func addTransaction(
        transaction: Transaction
    ) throws {
        
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
