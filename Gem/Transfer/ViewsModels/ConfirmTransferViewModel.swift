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

@Observable
class ConfirmTransferViewModel {
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

    private var metadata: TransferDataMetadata?

    private let data: TransferData
    private let wallet: Wallet
    private let keystore: any Keystore
    private let service: any ChainServiceable

    private let walletsService: WalletsService
    private let confirmTransferDelegate: ConfirmTransferDelegate?
    private let onComplete: VoidAction

    init(
        wallet: Wallet,
        keystore: any Keystore,
        data: TransferData,
        service: any ChainServiceable,
        walletsService: WalletsService,
        confirmTransferDelegate: ConfirmTransferDelegate? = .none,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.data = data
        self.service = service
        self.walletsService = walletsService
        self.confirmTransferDelegate = confirmTransferDelegate
        self.onComplete = onComplete
        self.feeModel = NetworkFeeSceneViewModel(chain: data.recipientData.asset.chain)

        // prefetch asset metadata from local storage
        let metadata = try? getAssetMetaData(walletId: wallet.id, asset: data.recipientData.asset, assetsIds: data.type.assetIds)
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
        if case .swap(_, _, let action) = dataModel.type, case .swap(let quote, _) = action, let slippage = quote.request.options {
            Double(Double(slippage.slippageBps) / 100).rounded(toPlaces: 2)
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
        if case .swap(_, _, let action) = dataModel.type, case .swap(let quote, _) = action, let fee = quote.request.options?.fee {
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
        await MainActor.run { [self] in
            self.state = .loading
        }

        do {
            let senderAddress = try wallet.account(for: dataModel.chain).address
            let metaData = try getAssetMetaData(walletId: wallet.id, asset: dataModel.asset, assetsIds: data.type.assetIds)
            let transactionInput = TransactionInput(
                type: data.type,
                asset: dataModel.asset,
                senderAddress: senderAddress,
                destinationAddress: dataModel.recipient.address,
                value: dataModel.data.value,
                balance: metaData.assetBalance,
                feePriority: feeModel.priority,
                memo: dataModel.memo
            )

            let preloadInput = try await service.load(input: transactionInput)
            let fee = preloadInput.fee
            let transactionInputModel = Self.buildTransactionInputModel(
                dataModel: dataModel,
                input: preloadInput,
                availableValue: availableValue,
                fee: fee.fee.totalFee,
                metaData: metaData
            )

            await MainActor.run { [self] in
                self.feeModel.set(
                    rates: fee.feeRates,
                    feeByPriority: fee.feeByPriority,
                    value: transactionInputModel.networkFeeText,
                    fiatValue: transactionInputModel.networkFeeFiatText
                )
                self.state = .loaded(transactionInputModel)
            }

        } catch {
            await MainActor.run { [self] in
                if !error.isCancelled {
                    self.state = .error(error)
                    NSLog("preload transaction error: \(error)")
                }
            }
        }
    }

    func onChangeFeePriority(_ priority: FeePriority) async {
        guard let currentTransactionInputModel = state.value,
              let preloadInput = currentTransactionInputModel.input,
              let metaData = metadata,
              let fee = feeModel.feeByPriority[priority]
        else { return }

        let transactionInputModel = Self.buildTransactionInputModel(
            dataModel: dataModel,
            input: preloadInput,
            availableValue: availableValue,
            fee: fee.totalFee,
            metaData: metaData
        )
        await MainActor.run { [self] in
            self.feeModel.update(
                value: transactionInputModel.networkFeeText,
                fiatValue: transactionInputModel.networkFeeFiatText
            )
            self.state = .loaded(transactionInputModel)
        }
    }

    func process(input: TransactionPreload, amount: TransferAmount) async {
        await MainActor.run { [self] in
            self.confirmingState = .loading
        }
        do {
            let signedData = try await sign(transferData: data, input: input, amount: amount)
            for data in signedData {
                let hash = try await broadcast(data: data, options: broadcastOptions)
                let transaction = try getTransaction(input: input, amount: amount, hash: hash)
                try addTransaction(transaction: transaction)

                // delay if multiple transaction should be exectured
                if signedData.count > 1 && data != signedData.last {
                    try await Task.sleep(for: transactionDelay)
                }
            }

            await MainActor.run { [self] in
                self.confirmingState = .loaded(true)
            }
        } catch {
            await MainActor.run { [self] in
                self.confirmingState = .error(error)
            }
            NSLog("confirm transaction error: \(error)")
        }
    }
    
    func onCompleteAction() {
        self.onComplete?()
    }
}

// MARK: - Private

extension ConfirmTransferViewModel {
    private var transactionDelay: Duration {
        .milliseconds(500)
    }

    private enum AssetMetadataError: Error {
        case missingBalance
        case invalidAssetId
    }

    private var senderLink: BlockExplorerLink {
        ExplorerService.main.addressUrl(chain: dataModel.chain, address: senderAddress)
    }

    private var broadcastOptions: BroadcastOptions {
        switch dataModel.chain {
        case .solana:
            switch dataModel.type {
            case .transfer, .stake: .standard
            case .swap, .generic: BroadcastOptions(skipPreflight: true)
            }
        default: .standard
        }
    }

    private var availableValue: BigInt {
        switch dataModel.type {
        case .transfer(let asset), .swap(let asset, _, _), .generic(let asset, _, _):
            guard let balance = try? walletsService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
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
        let senderAddress = try wallet.account(for: transferData.recipientData.asset.chain).address

        return try await Self.sign(
            signer: signer,
            senderAddress: senderAddress,
            transferData: transferData,
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

    private func addTransaction(transaction: Primitives.Transaction) throws {
        try walletsService.addTransaction(walletId: wallet.id, transaction: transaction)
    }

    private func getTransaction(
        input: TransactionPreload,
        amount: TransferAmount,
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

// MARK: - Static

extension ConfirmTransferViewModel {
    static func buildTransactionInputModel(
            dataModel: TransferDataViewModel,
            input: TransactionPreload,
            availableValue: BigInt,
            fee: BigInt,
            metaData: TransferDataMetadata
    ) -> TransactionInputViewModel {
        let transferAmountResult = TransferAmountCalculator().calculateResult(
            input: TranferAmountInput(
                asset: dataModel.asset,
                assetBalance: Balance(available: metaData.assetBalance),
                value: dataModel.data.value,
                availableValue: availableValue,
                assetFee: dataModel.asset.feeAsset,
                assetFeeBalance: Balance(available: metaData.assetFeeBalance),
                fee: fee,
                canChangeValue: dataModel.data.canChangeValue,
                ignoreValueCheck: dataModel.data.ignoreValueCheck
            )
        )

        return TransactionInputViewModel(
            data: dataModel.data,
            input: input,
            metaData: metaData,
            transferAmountResult: transferAmountResult
        )
    }

    static func sign(signer: Signer,
                     senderAddress: String,
                     transferData: TransferData,
                     input: TransactionPreload,
                     amount: TransferAmount) async throws -> [String] {
        let destinationAddress = transferData.recipientData.recipient.address
        let isMaxAmount = amount.useMaxAmount

        let fee = Fee(
            fee: amount.networkFee,
            gasPriceType: input.fee.fee.gasPriceType,
            gasLimit: input.fee.fee.gasLimit,
            options: input.fee.fee.options
        )

        let input = SignerInput(
            type: transferData.type,
            asset: transferData.recipientData.asset,
            value: amount.value,
            fee: fee,
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
}
