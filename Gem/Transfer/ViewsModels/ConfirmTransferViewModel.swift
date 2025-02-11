// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import Blockchain
import BigInt
import Components
import Signer
import Style
import GemstonePrimitives
import SwiftUI
import Localization
import Transfer
import PrimitivesComponents
import WalletConnector
import ExplorerService
import WalletsService

@Observable
@MainActor
final class ConfirmTransferViewModel {
    var state: StateViewType<TransactionInputViewModel> = .loading
    var confirmingState: StateViewType<Bool> = .noData {
        didSet {
            if case let .error(error) = confirmingState {
                confirmingErrorMessage = error.localizedDescription
            } else {
                confirmingErrorMessage = nil
            }
        }
    }
    var feeModel: NetworkFeeSceneViewModel

    var isPresentedNetworkFeePicker: Bool = false
    var confirmingErrorMessage: String?

    let explorerService: any ExplorerLinkFetchable

    private var metadata: TransferDataMetadata?

    private let data: TransferData
    private let wallet: Wallet
    private let keystore: any Keystore
    private let service: any ChainServiceable

    private let walletsService: WalletsService
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate?
    private let onComplete: VoidAction

    init(
        wallet: Wallet,
        keystore: any Keystore,
        data: TransferData,
        service: any ChainServiceable,
        walletsService: WalletsService,
        explorerService: any ExplorerLinkFetchable = ExplorerService.standard,
        confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate? = .none,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.data = data
        self.service = service
        self.explorerService = explorerService
        self.walletsService = walletsService
        self.confirmTransferDelegate = confirmTransferDelegate
        self.onComplete = onComplete
        self.feeModel = NetworkFeeSceneViewModel(chain: data.chain, service: service)

        // prefetch asset metadata from local storage
        let metadata = try? getAssetMetaData(walletId: wallet.id, asset: data.type.asset, assetsIds: data.type.assetIds)
        self.metadata = metadata
    }

    var title: String { dataModel.title }

    var appTitle: String { Localized.WalletConnect.app }
    var appValue: String? { dataModel.appValue }

    var websiteURL: URL? { dataModel.websiteURL }
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
        (try? wallet.account(for: dataModel.chain).address) ?? ""
    }

    var senderAddressExplorerUrl: URL { senderLink.url }
    var senderExplorerText: String { Localized.Transaction.viewOn(senderLink.name) }

    var shouldShowRecipientField: Bool { dataModel.shouldShowRecipient }
    var recipientTitle: String { dataModel.recipientTitle }
    var recipientValue: SimpleAccount { dataModel.recepientAccount }

    var networkTitle: String { Localized.Transfer.network }
    var networkValue: String { dataModel.chainAsset.name }

    var networkAssetImage: AssetImage {
        AssetIdViewModel(assetId: dataModel.chainAsset.id).networkAssetImage
    }

    var networkFeeTitle: String { feeModel.title }
    var networkFeeValue: String? {
        state.isError ? "-" : feeModel.value
    }

    var networkFeeFiatValue: String? {
        state.isError ? nil : feeModel.fiatValue
    }

    var networkFeeInfoUrl: URL {
        Docs.url(.networkFees)
    }

    var buttonTitle: String {
        // try again on failed data load
        if state.isError {
            return Localized.Common.tryAgain
        }
        
        // error message on success data load and calculator
        if let result = state.value?.transferAmountResult,
           case .error(_, let error) = result {
            let title: String = {
                switch error {
                case let tranferError as TransferAmountCalculatorError:
                    switch tranferError {
                    case .insufficientBalance(let asset):
                        return Localized.Transfer.insufficientBalance(AssetViewModel(asset: asset).title)
                    case .insufficientNetworkFee(let asset):
                        return Localized.Transfer.insufficientNetworkFeeBalance(AssetViewModel(asset: asset).title)
                    }
                default:
                    return Localized.Errors.unknown
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

        let authentication = (try? keystore.getPasswordAuthentication()) ?? .none
        return KeystoreAuthenticationViewModel(authentication: authentication).authenticationImage
    }

    var shouldDisableButton: Bool {
        if let result = state.value?.transferAmountResult, case .error = result {
            return true
        }
        return state.isNoData
    }

    var shouldShowMemo: Bool {
        dataModel.shouldShowMemo
    }

    var memo: String? {
        dataModel.recipientData.recipient.memo
    }
    
    var slippageField: String? {
        Localized.Swap.slippage
    }
    
    private var slippage: Double? {
        if case .swap(_, _, let quote, _) = dataModel.type {
            Double(Double(quote.request.options.slippage.bps) / 100).rounded(toPlaces: 2)
        } else {
            .none
        }
    }
    
    var slippageText: String? {
        if let slippage {
            String("\(slippage)%")
        } else {
            .none
        }
    }
    
    private var quoteFee: Double? {
        if case .swap(_, _, let quote, _) = dataModel.type, let fee = quote.request.options.fee {
             Double(Double(fee.evm.bps) / 100).rounded(toPlaces: 2)
        } else {
            .none
        }
    }

    var networkFeeFooterText: String? {
        return .none
//        TODO: Enable later
//        if let quoteFee {
//            Localized.Swap.quoteFee("\(quoteFee)%")
//        } else {
//            .none
//        }
    }
    
    var headerType: TransactionHeaderType {
        if let value = state.value {
            return value.headerType
        }
        return TransactionInputViewModel(data: dataModel.data, input: nil, metaData: metadata, transferAmountResult: nil).headerType
    }

    var progressMessage: String { Localized.Common.loading }
    var shouldShowFeeRatesSelector: Bool {
        feeModel.showFeeRatesSelector
    }

    var dataModel: TransferDataViewModel {
        TransferDataViewModel(data: data)
    }
}

// MARK: - Business Logic

extension ConfirmTransferViewModel {
    func fetch() async {
        state = .loading
        feeModel.reset()

        do {
            let senderAddress = try wallet.account(for: dataModel.chain).address
            let metaData = try getAssetMetaData(walletId: wallet.id, asset: dataModel.asset, assetsIds: data.type.assetIds)
            let rates = try await feeModel.getFeeRates(type: data.type)

            guard let rate = rates.first(where: { $0.priority == feeModel.priority }) else {
                throw ChainCoreError.feeRateMissed
            }

            let transactionInput = TransactionInput(
                type: data.type,
                asset: dataModel.asset,
                senderAddress: senderAddress,
                destinationAddress: dataModel.recipient.address,
                value: dataModel.data.value,
                balance: metaData.assetBalance,
                gasPrice: rate.gasPriceType,
                memo: dataModel.memo
            )

            let preloadInput = try await service.load(input: transactionInput)
            let fee = preloadInput.fee

            let transferAmountResult = TransferAmountCalculator().calculateResult(
                input: TranferAmountInput(
                    asset: dataModel.asset,
                    assetBalance: Balance(available: metaData.assetBalance),
                    value: dataModel.data.value,
                    availableValue: availableValue,
                    assetFee: dataModel.asset.feeAsset,
                    assetFeeBalance: Balance(available: metaData.assetFeeBalance),
                    fee: fee.totalFee,
                    canChangeValue: dataModel.data.canChangeValue,
                    ignoreValueCheck: dataModel.data.ignoreValueCheck
                )
            )
            
            let transactionInputModel = TransactionInputViewModel(
                data: data,
                input: preloadInput,
                metaData: metaData,
                transferAmountResult: transferAmountResult
            )
            
            feeModel.update(
                value: transactionInputModel.networkFeeText,
                fiatValue: transactionInputModel.networkFeeFiatText
            )
            state = .loaded(transactionInputModel)
        } catch {
            if !error.isCancelled {
                state = .error(error)
                NSLog("preload transaction error: \(error)")
            }
        }
    }

    func process(input: TransactionPreload, amount: TransferAmount) async -> Void {
        confirmingState = .loading
        do {
            let signedData = try await sign(transferData: data, input: input, amount: amount)
            for (index, transactionData) in signedData.enumerated() {
                switch self.data.type.outputType {
                case .encodedTransaction:
                    let hash = try await broadcast(data: transactionData, options: broadcastOptions)
                    let transaction = try getTransaction(
                        wallet: wallet,
                        input: input,
                        transferDataType: self.data.type,
                        recipientData: self.data.recipientData,
                        amount: amount,
                        hash: hash,
                        index: index
                    )
                    try addTransactions(transactions: [transaction])
                    
                    walletsService.enableAssetId(walletId: wallet.walletId, assets: transaction.assetIds, enabled: true)
                    
                    // delay if multiple transaction should be exectured
                    if signedData.count > 1 && transactionData != signedData.last {
                        try await Task.sleep(for: transactionDelay)
                    }
                case .signature:
                    confirmTransferDelegate?(.success(transactionData))
                }
            }
            confirmingState = .loaded(true)
        } catch {
            confirmingState = .error(error)
            NSLog("confirm transaction error: \(error)")
        }
    }
    
    func onCompleteAction() {
        self.onComplete?()
    }
}

// MARK: - Actions

extension ConfirmTransferViewModel {
    
}

// MARK: - Private

extension ConfirmTransferViewModel {
    private var transactionDelay: Duration {
        switch data.chain.type {
        case .ethereum: .milliseconds(0)
        case .tron: .milliseconds(500)
        default: .milliseconds(500)
        }
    }

    private enum AssetMetadataError: Error {
        case missingBalance
        case invalidAssetId
    }

    private var senderLink: BlockExplorerLink {
        explorerService.addressUrl(chain: dataModel.chain, address: senderAddress)
    }

    private var broadcastOptions: BroadcastOptions {
        switch dataModel.chain {
        case .solana:
            switch dataModel.type {
            case .transfer, .transferNft, .stake, .account, .tokenApprove: .standard
            case .swap, .generic: BroadcastOptions(skipPreflight: true)
            }
        default: .standard
        }
    }

    private var availableValue: BigInt {
        switch dataModel.type {
        case .transfer(let asset),
            .swap(let asset, _, _, _),
            .tokenApprove(let asset, _),
            .generic(let asset, _, _):
            guard let balance = try? walletsService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
            return balance.available
        case .transferNft(let asset):
            guard let balance = try? walletsService.balanceService.getBalance(walletId: wallet.id, assetId: asset.chain.id) else {
                return .zero
            }
            return balance.available
        case .stake(let asset, let stakeType):
            switch stakeType {
            case .stake:
                guard let balance = try? walletsService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
                return balance.available
            case .unstake(let delegation):
                return delegation.base.balanceValue
            case .redelegate(let delegation, _):
                return delegation.base.balanceValue
            case .rewards:
                return dataModel.data.value
            case .withdraw(let delegation):
                return delegation.base.balanceValue
            }
        case .account(let asset, let type):
            guard let balance = try? walletsService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
            switch type {
            case .activate: return balance.available
            }
        }
    }

    private func getAssetMetaData(walletId: String, asset: Asset, assetsIds: [AssetId]) throws -> TransferDataMetadata {
        let assetId = asset.id
        let feeAssetId = asset.feeAsset.id

        guard let assetBalance = try walletsService.balanceService.getBalance(walletId: walletId, assetId: assetId.identifier),
              let assetFeeBalance = try walletsService.balanceService.getBalance(walletId: walletId, assetId: feeAssetId.identifier) else {
            throw AssetMetadataError.missingBalance
        }

        let assetPricesIds: [AssetId] = [assetId, feeAssetId] + assetsIds
        let assetPrices = try walletsService.priceService.getPrices(for: assetPricesIds).toMap {
            try AssetId(id: $0.assetId)
        }
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

    private func sign(transferData: TransferData, input: TransactionPreload, amount: TransferAmount) async throws -> [String]  {
        let signer = Signer(wallet: wallet, keystore: keystore)
        return try await Self.sign(
            signer: signer,
            wallet: wallet,
            type: transferData.type,
            recipientData: transferData.recipientData,
            input: input,
            amount: amount
        )
    }

    private func broadcast(data: String, options: BroadcastOptions) async throws -> String  {
        NSLog("broadcast data \(data)")
        
        let hash = try await service.broadcast(data: data, options: options)
        
        NSLog("broadcast response \(hash)")
        confirmTransferDelegate?(.success(hash))

        return hash
    }

    private func addTransactions(transactions: [Primitives.Transaction]) throws {
        try walletsService.addTransactions(walletId: wallet.id, transactions: transactions)
    }

    private func getTransaction(
        wallet: Wallet,
        input: TransactionPreload,
        transferDataType: TransferDataType,
        recipientData: RecipientData,
        amount: TransferAmount,
        hash: String,
        index: Int
    ) throws -> Primitives.Transaction {
        let senderAddress = try wallet.account(for: transferDataType.chain).address
        let direction: TransactionDirection = {
            if recipientData.recipient.address == senderAddress {
                return .selfTransfer
            }
            return .outgoing
        }()
        
        let transactionType: TransactionType = switch transferDataType {
        case .swap(_, _, _, let data):
            switch data.approval {
            case .some: index == 0 ? .tokenApproval : .swap
            case .none: .swap
            }
        default: transferDataType.transactionType
        }
        
        return Transaction(
            id: Transaction.id(chain: transferDataType.chain, hash: hash),
            hash: hash,
            assetId: transferDataType.asset.id,
            from: senderAddress,
            to: recipientData.recipient.address,
            contract: .none,
            type: transactionType,
            state: .pending,
            blockNumber: String(input.block.number),
            sequence: input.sequence.asString,
            fee: amount.networkFee.description,
            feeAssetId: transferDataType.asset.feeAsset.id,
            value: amount.value.description,
            memo: recipientData.recipient.memo ?? "",
            direction: direction,
            utxoInputs: [],
            utxoOutputs: [],
            metadata: transferDataType.metadata,
            createdAt: Date()
        )
    }
}

// MARK: - Static

extension ConfirmTransferViewModel {
    static func sign(
        signer: Signer,
        wallet: Wallet,
        type: TransferDataType,
        recipientData: RecipientData,
        input: TransactionPreload,
        amount: TransferAmount
    ) async throws -> [String] {
        let destinationAddress = recipientData.recipient.address
        let isMaxAmount = amount.useMaxAmount
        
        let senderAddress = try wallet.account(for: type.chain).address
        
        let input = SignerInput(
            type: type,
            asset: type.asset,
            value: amount.value,
            fee: Fee(
                fee: amount.networkFee,
                gasPriceType: input.fee.gasPriceType,
                gasLimit: input.fee.gasLimit,
                options: input.fee.options
            ),
            isMaxAmount: isMaxAmount,
            chainId: input.chainId,
            memo: recipientData.recipient.memo,
            accountNumber: input.accountNumber,
            sequence: input.sequence,
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            data: input.data,
            block: input.block,
            token: input.token,
            utxos: input.utxos,
            messageBytes: input.messageBytes,
            extra: input.extra
        )

        return try signer.sign(input: input)
    }
}
