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
import Style

@Observable
@MainActor
public final class ConfirmTransferViewModel {
    var feeModel: NetworkFeeSceneViewModel
    var state: StateViewType<TransactionInputViewModel> = .loading
    var confirmingState: StateViewType<Bool> = .noData {
        didSet {
            if case .error(let error) = confirmingState {
                isPresentingErrorMessage = error.localizedDescription
            } else {
                isPresentingErrorMessage = nil
            }
        }
    }

    var isPresentingSheet: ConfirmTransferSheetType?
    var isPresentingErrorMessage: String?

    private let explorerService: any ExplorerLinkFetchable
    private let metadataProvider: any TransferMetadataProvidable
    private let transferTransactionProvider: any TransferTransactionProvidable
    private let transerExecutor: any TransferExecutable
    private let keystore: any Keystore

    private let data: TransferData
    private let wallet: Wallet
    private let onComplete: VoidAction
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate?

    private var metadata: TransferDataMetadata?

    public init(
        wallet: Wallet,
        data: TransferData,
        keystore: any Keystore,
        chainService: any ChainServiceable,
        scanService: ScanService,
        walletsService: WalletsService,
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
            scanService: scanService
        )

        self.transerExecutor = TransferExecutor(
            signer: TransactionSigner(keystore: keystore),
            chainService: chainService,
            walletsService: walletsService
        )

        self.metadata = try? metadataProvider.metadata(wallet: wallet, data: data)
    }

    var title: String { dataModel.title }
    var appTitle: String { Localized.WalletConnect.app }
    var appValue: String? { dataModel.appValue }

    var appAssetImage: AssetImage? { dataModel.appAssetImage }

    var websiteURL: URL? { dataModel.websiteURL }
    var websiteTitle: String { Localized.WalletConnect.website }
    var websiteValue: String? {
        guard let url = websiteURL,
              let host = url.host(percentEncoded: true)
        else {
            return .none
        }
        return host
    }

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

    var slippageField: String? { Localized.Swap.slippage }
    var progressMessage: String { Localized.Common.loading }
    var shouldShowFeeRatesSelector: Bool { feeModel.showFeeRatesSelector }

    var slippageText: String? {
        if let slippage = dataModel.slippage {
            String("\(slippage)%")
        } else {
            .none
        }
    }

    var networkFeeFooterText: String? {
        return .none
        //        TODO: Enable later
        //        if let quoteFee = dataModel.quoteFee {
        //            Localized.Swap.quoteFee("\(quoteFee)%")
        //        } else {
        //            .none
        //        }
    }

    var buttonTitle: String {
        // try again on failed data load
        if state.isError { return Localized.Common.tryAgain }

        switch state.value?.transferAmount {
        case .success, .none: return Localized.Transfer.confirm
        case .failure: return "Insufficient funds"
        }
    }

    var buttonType: ButtonType {
        isPrimaryButtonState ? .primary(state, isDisabled: state.isNoData) : .secondary
    }

    var buttonImage: String? {
        guard !state.isError else { return nil }
        if state.value?.transferAmount?.isFailure ?? true { return nil }

        let authentication = (try? keystore.getPasswordAuthentication()) ?? .none
        return KeystoreAuthenticationViewModel(authentication: authentication).authenticationImage
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
}

// MARK: - Business Logic

extension ConfirmTransferViewModel {
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

    func onChangeFeePriority(_ priority: FeePriority) async {
        await fetch()
    }

    func onSelectConfirmButton() {
        if state.isError {
            fetch()
        } else {
            switch buttonType {
            case .primary:
                onSelectConfirmTransfer()
            case .secondary:
                isPresentingSheet = .fiatConnect(assetAddress: assetAddress, waletId: wallet.walletId)
            }
        }
    }

    func fetch() {
        Task {
            await fetch()
        }
    }
}

// MARK: - Private

extension ConfirmTransferViewModel {
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
                data: data,
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
    
    private var isPrimaryButtonState: Bool {
        switch state {
        case .noData, .loading, .error: true
        case let .data(value): value.transferAmount?.isSuccess ?? false
        }
    }
    private var assetAddress: AssetAddress { AssetAddress(asset: dataModel.asset, address: senderAddress)}
}
