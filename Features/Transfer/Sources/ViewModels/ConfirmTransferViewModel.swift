// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Blockchain
import Components
import ExplorerService
import Keystore
import Localization
import Primitives
import PrimitivesComponents
import ScanService
import WalletConnector
import WalletsService
import InfoSheet
import Signer
import Validators
import SwapService
import Style
import SwiftUI
import Formatters
import Swap

@Observable
@MainActor
public final class ConfirmTransferViewModel {
    var feeModel: NetworkFeeSceneViewModel
    var state: StateViewType<TransactionInputViewModel> = .loading {
        didSet {
            if case .data(let data) = state, case .failure(let error) =  data.transferAmount {
                onSelectListError(error: error)
            }
        }
    }

    var confirmingState: StateViewType<Bool> = .noData {
        didSet {
            if case .error(let error) = confirmingState {
                isPresentingAlertMessage = AlertMessage(
                    title: Localized.Errors.transferError,
                    message: error.localizedDescription
                )
            } else {
                isPresentingAlertMessage = nil
            }
        }
    }

    var isPresentingSheet: ConfirmTransferSheetType?
    var isPresentingAlertMessage: AlertMessage?

    private let swapDataProvider: any SwapQuoteDataProvidable
    private let explorerService: any ExplorerLinkFetchable
    private let metadataProvider: any TransferMetadataProvidable
    private let transferTransactionProvider: any TransferTransactionProvidable
    private let transerExecutor: any TransferExecutable
    private let keystore: any Keystore
    private let swapService: SwapService

    private let wallet: Wallet
    private let onComplete: VoidAction
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate?

    private var data: TransferData
    private var metadata: TransferDataMetadata?

    public init(
        wallet: Wallet,
        data: TransferData,
        keystore: any Keystore,
        chainService: any ChainServiceable,
        scanService: ScanService,
        swapService: SwapService,
        walletsService: WalletsService,
        swapDataProvider: any SwapQuoteDataProvidable,
        explorerService: any ExplorerLinkFetchable = ExplorerService.standard,
        confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate? = .none,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.data = data

        self.explorerService = explorerService
        self.confirmTransferDelegate = confirmTransferDelegate
        self.onComplete = onComplete

        self.feeModel = NetworkFeeSceneViewModel(
            chain: data.chain,
            priority: chainService.defaultPriority(for: data.type)
        )

        self.metadataProvider = TransferMetadataProvider(
            balanceService: walletsService.balanceService,
            priceService: walletsService.priceService
        )

        self.transferTransactionProvider = TransferTransactionProvider(
            chainService: chainService,
            scanService: scanService,
            swapService: swapService
        )
        self.swapService = swapService

        self.transerExecutor = TransferExecutor(
            signer: TransactionSigner(keystore: keystore),
            chainService: chainService,
            walletsService: walletsService
        )
        self.swapDataProvider = swapDataProvider
        self.metadata = try? metadataProvider.metadata(wallet: wallet, data: data)
    }

    var title: String { dataModel.title }
    var appTitle: String { Localized.WalletConnect.app }
    var appAssetImage: AssetImage? { dataModel.appAssetImage }
    var appText: String {
        AppDisplayFormatter.format(name: dataModel.appValue, host: websiteURL?.cleanHost())
    }
    var websiteURL: URL? { dataModel.websiteURL }
    var websiteTitle: String {Localized.Settings.website }

    var senderTitle: String { Localized.Wallet.title }
    var senderValue: String { wallet.name }
    var senderAddress: String { (try? wallet.account(for: dataModel.chain).address) ?? "" }
    var senderAssetImage: AssetImage? {
        let viewModel = WalletViewModel(wallet: wallet)
        return viewModel.hasAvatar ? viewModel.avatarImage : .none
    }
    var senderAddressExplorerUrl: URL { senderLink.url }
    var senderExplorerText: String { Localized.Transaction.viewOn(senderLink.name) }

    var shouldShowRecipient: Bool { dataModel.shouldShowRecipient }
    var recipientAddressViewModel: AddressListItemViewModel {
        AddressListItemViewModel(
            title: dataModel.recipientTitle,
            account: dataModel.recepientAccount,
            mode: dataModel.recipientMode,
            explorerService: explorerService
        )
    }

    var networkTitle: String { Localized.Transfer.network }
    var networkValue: String { AssetViewModel(asset: dataModel.asset).networkFullName }
    var networkAssetImage: AssetImage { AssetIdViewModel(assetId: dataModel.chainAsset.id).networkAssetImage }

    var networkFeeTitle: String { feeModel.title }
    var networkFeeValue: String? { state.isError ? "-" : feeModel.value }
    var networkFeeFiatValue: String? { state.isError ? nil : feeModel.fiatValue }

    var shouldShowMemo: Bool { dataModel.shouldShowMemo }
    var memo: String? { dataModel.recipientData.recipient.memo }

    var progressMessage: String { Localized.Common.loading }
    var shouldShowFeeRatesSelector: Bool { feeModel.showFeeRatesSelector }

    var networkFeeFooterText: String? {
        return .none
        //        TODO: Enable later
        //        if let quoteFee = dataModel.quoteFee {
        //            Localized.Swap.quoteFee("\(quoteFee)%")
        //        } else {
        //            .none
        //        }
    }

    var listError: Error? {
        if case let .error(error) = state {
            return error
        }
        if case let .failure(error) = state.value?.transferAmount {
            return error
        }

        return nil
    }
    var listErrorTitle: String { Localized.Errors.errorOccured }
    var shouldShowListErrorInfo: Bool {
        switch state.value?.transferAmount {
        case .success, .none: false
        case .failure: true
        }
    }

    var showClearHeader: Bool {
        switch headerType {
        case .amount, .nft: true
        case .swap: false
        }
    }

    var headerType: TransactionHeaderType {
        if let value = state.value {
            return value.headerType
        }
        return TransactionInputViewModel(
            data: dataModel.data,
            transactionData: nil,
            metaData: metadata,
            transferAmount: nil
        ).headerType
    }

    var confirmButtonModel: ConfirmButtonViewModel {
        ConfirmButtonViewModel(
            state: state,
            icon: confirmButtonIcon,
            onAction: { [weak self] in
                guard let self else { return }
                if case .data(let data) = state, data.isReady {
                    onSelectConfirmTransfer()
                } else {
                    self.fetch()
                }
            }
        )
    }

    var swapDetailsViewModel: SwapDetailsViewModel? {
        guard case let .swap(fromAsset, toAsset, quote, _) = data.type else {
            return nil
        }

        return SwapDetailsViewModel(
            fromAssetPrice: AssetPriceValue(asset: fromAsset, price: metadata?.assetPrice),
            toAssetPrice: AssetPriceValue(asset: toAsset, price: metadata?.assetPrices[toAsset.id]),
            selectedQuote: quote,
            availableQuotes: [quote]
        )
    }
}

// MARK: - Business Logic

extension ConfirmTransferViewModel {
    func onSelectListError(error: Error) {
        switch error {
        case let error as TransferAmountCalculatorError:
            switch error {
            case .insufficientBalance, .minimumAccountBalanceTooLow:
                isPresentingSheet = .info(error.infoSheet)
            case .insufficientNetworkFee(let asset, _):
                isPresentingSheet = .infoAction(
                    error.infoSheet,
                    button: .action(title: Localized.Asset.buyAsset(asset.feeAsset.symbol)) {
                        self.onSelectBuy()
                    }
                )
            }
        default:
            break
            //TODO Generic error
        }
    }

    func onSelectNetworkFeeInfo() {
        isPresentingSheet = .info(.networkFee(dataModel.chain))
    }

    func onSelectSlippageInfo() {
        isPresentingSheet = .info(.slippage)
    }

    func onSelectOpenWebsiteURL() {
        if let websiteURL {
            isPresentingSheet = .url(websiteURL)
        }
    }

    func onSelectOpenSenderAddressURL() {
        isPresentingSheet = .url(senderAddressExplorerUrl)
    }

    func onSelectFeePicker() {
        isPresentingSheet = .networkFeeSelector
    }

    func onSelectSwapDetails() {
        isPresentingSheet = .swapDetails
    }

    func onChangeFeePriority(_ priority: FeePriority) async {
        await fetch()
    }

    func fetch() {
        Task {
            await fetch()
        }
    }
}

// MARK: - Private

extension ConfirmTransferViewModel {
    private func onSelectBuy() {
        isPresentingSheet = .fiatConnect(
            assetAddress: feeAssetAddress,
            walletId: wallet.walletId
        )
    }
    private func onSelectConfirmTransfer() {
        guard let value = state.value,
              let transactionData = value.transactionData,
              case .success(let amount) = value.transferAmount
        else { return }
        confirmTransfer(transactionData: transactionData, amount: amount)
    }

    private func confirmTransfer(
        transactionData: TransactionData,
        amount: TransferAmount
    ) {
        Task {
            await processConfirmation(
                transactionData: transactionData,
                amount: amount
            )
            if case .data(_) = confirmingState {
                onComplete?()
            }
        }
    }


    private func fetch() async {
        state = .loading
        feeModel.reset()

        do {
            let metadata = try metadataProvider.metadata(wallet: wallet, data: data)
            let transferTransactionData = try await transferTransactionProvider.loadTransferTransactionData(
                wallet: wallet, data: data,
                priority: feeModel.priority,
                available: metadata.available
            )
            let transferAmount = calculateTransferAmount(
                assetBalance: metadata.assetBalance,
                assetFeeBalance: metadata.assetFeeBalance,
                fee: transferTransactionData.transactionData.fee.fee
            )

            self.metadata = metadata
            self.feeModel.update(rates: transferTransactionData.rates)
            self.updateState(
                with: transactionInputViewModel(
                    transferAmount: transferAmount,
                    input: transferTransactionData.transactionData,
                    metaData: metadata
                )
            )
        } catch {
            if !error.isCancelled {
                state = .error(error)
                NSLog("preload transaction error: \(error)")
            }
        }
    }

    private func processConfirmation(transactionData: TransactionData, amount: TransferAmount) async {
        confirmingState = .loading
        do {
            let input = TransferConfirmationInput(
                data: state.value!.data,
                wallet: wallet,
                transactionData: transactionData,
                amount: amount,
                delegate: confirmTransferDelegate
            )
            try await transerExecutor.execute(input: input)
            confirmingState = .data(true)
        } catch {
            confirmingState = .error(error)
            NSLog("confirm transaction error: \(error)")
        }
    }

    private func updateState(with model: TransactionInputViewModel) {
        feeModel.update(
            value: model.networkFeeText,
            fiatValue: model.networkFeeFiatText
        )
        state = .data(model)
    }

    private func calculateTransferAmount(
        assetBalance: Balance,
        assetFeeBalance: Balance,
        fee: BigInt
    ) -> TransferAmountValidation {
        let input = TransferAmountInput(
            asset: dataModel.asset,
            assetBalance: assetBalance,
            value: dataModel.data.value,
            availableValue: availableValue,
            assetFee: dataModel.asset.feeAsset,
            assetFeeBalance: assetFeeBalance,
            fee: fee,
            canChangeValue: dataModel.data.canChangeValue,
            ignoreValueCheck: dataModel.data.ignoreValueCheck
        )
        return TransferAmountCalculator().validate(input: input)
    }

    private func transactionInputViewModel(
        transferAmount: TransferAmountValidation,
        input: TransactionData? = nil,
        metaData: TransferDataMetadata? = nil
    ) -> TransactionInputViewModel {
        TransactionInputViewModel(
            data: data,
            transactionData: input,
            metaData: metaData,
            transferAmount: transferAmount
        )
    }

    private var dataModel: TransferDataViewModel { TransferDataViewModel(data: data) }
    private var availableValue: BigInt { dataModel.availableValue(metadata: metadata) }
    private var senderLink: BlockExplorerLink { explorerService.addressUrl(chain: dataModel.chain, address: senderAddress) }
    private var feeAssetAddress: AssetAddress { AssetAddress(asset: dataModel.asset.feeAsset, address: senderAddress)}
    private var confirmButtonIcon: Image? {
        guard !state.isError, state.value?.transferAmount?.isSuccess ?? false,
              let auth = try? keystore.getPasswordAuthentication(),
              let systemName = KeystoreAuthenticationViewModel(authentication: auth).authenticationImage
        else { return nil }
        return Image(systemName: systemName)
    }
}

extension TransferAmountCalculatorError {
    var infoSheet: InfoSheetType {
        switch self {
        case .insufficientBalance(let asset):
            .insufficientBalance(asset, image: AssetViewModel(asset: asset).assetImage)
        case .insufficientNetworkFee(let asset, let required):
                .insufficientNetworkFee(asset, image: AssetViewModel(asset: asset).assetImage, required: required)
        case .minimumAccountBalanceTooLow(let asset, let required):
            .accountMinimalBalance(asset, required: required)
        }
    }
}
