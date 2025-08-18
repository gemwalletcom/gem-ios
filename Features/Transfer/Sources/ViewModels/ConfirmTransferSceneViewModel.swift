// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Blockchain
import Components
import Localization
import Primitives
import PrimitivesComponents
import WalletConnector
import InfoSheet
import Validators
import Style
import SwiftUI
import Formatters
import Swap

@Observable
@MainActor
public final class ConfirmTransferSceneViewModel {
    var feeModel: NetworkFeeSceneViewModel
    var state: StateViewType<TransactionInputViewModel> = .loading {
        didSet {
            onStateChange(state: state)
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

    private let confirmService: ConfirmService

    private let wallet: Wallet
    private let onComplete: VoidAction
    private let confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate?

    private var data: TransferData
    private var metadata: TransferDataMetadata?

    public init(
        wallet: Wallet,
        data: TransferData,
        confirmService: ConfirmService,
        confirmTransferDelegate: TransferDataCallback.ConfirmTransferDelegate? = .none,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.data = data
        self.confirmService = confirmService
        self.confirmTransferDelegate = confirmTransferDelegate
        self.onComplete = onComplete

        self.feeModel = NetworkFeeSceneViewModel(
            chain: data.chain,
            priority: confirmService.defaultPriority(for: data.type)
        )

        self.metadata = try? confirmService.getMetadata(wallet: wallet, data: data)
    }

    var title: String { dataModel.title }
    var appTitle: String { Localized.WalletConnect.app }
    var appAssetImage: AssetImage? { dataModel.appAssetImage }
    var appText: String? {
        if let value = dataModel.appValue {
            return AppDisplayFormatter.format(name: value, host: websiteURL?.cleanHost())
        }
        return .none
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
            account: SimpleAccount(
                name: try? confirmService.getAddressName(chain: dataModel.chain, address: dataModel.recipient.address)?.name ?? dataModel.recipient.name,
                chain: dataModel.chain,
                address: dataModel.recipient.address,
                assetImage: .none
            ),
            mode: .nameOrAddress,
            addressLink: confirmService.getExplorerLink(chain: dataModel.chain, address: dataModel.recipient.address)
        )
    }

    var networkTitle: String { Localized.Transfer.network }
    var networkText: String {
        let model = AssetViewModel(asset: dataModel.asset)
        switch data.type {
        case .transfer, .deposit, .withdrawal:
            return model.networkFullName
        case .transferNft, .swap, .tokenApprove, .stake, .account, .generic, .perpetual:
            return model.networkName
        }
    }
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
        guard case let .swap(fromAsset, toAsset, swapData) = data.type else {
            return nil
        }
        return SwapDetailsViewModel(
            fromAssetPrice: AssetPriceValue(asset: fromAsset, price: metadata?.assetPrice),
            toAssetPrice: AssetPriceValue(asset: toAsset, price: metadata?.assetPrices[toAsset.id]),
            selectedQuote: swapData.quote
        )
    }
    
    @SectionBuilder<TransferSection>
    var listSections: [TransferSection] {
        [
            .main {
                if let appText = appText {
                    .entity(
                        appTitle,
                        name: appText,
                        image: appAssetImage,
                        contextMenu: ContextMenuConfiguration(
                            item: .url(title: websiteTitle, onOpen: onSelectOpenWebsiteURL)
                        )
                    )
                }

                [
                    .sender(
                        senderTitle,
                        name: senderValue,
                        image: senderAssetImage,
                        menu: ContextMenuConfiguration(items: [
                            .copy(value: senderAddress),
                            .url(title: senderExplorerText, onOpen: onSelectOpenSenderAddressURL)
                        ])
                    ),
                    .network(networkTitle, name: networkText, image: networkAssetImage)
                ]

                if shouldShowRecipient {
                    .address(viewModel: recipientAddressViewModel)
                }

                if shouldShowMemo, let memo = memo {
                    .memo(memo)
                }

                if let swapDetailsViewModel = swapDetailsViewModel {
                    .swapDetails(viewModel: swapDetailsViewModel)
                }
            },
            .fee {
                .fee(
                    networkFeeTitle,
                    value: networkFeeValue,
                    fiat: networkFeeFiatValue,
                    selectable: shouldShowFeeRatesSelector,
                    onSelect: onSelectFeePicker,
                    onInfo: onSelectNetworkFeeInfo
                )
            }
        ]

        if let error = listError {
            TransferSection.error {
                .error(
                    listErrorTitle,
                    error: error,
                    action: { [weak self] in
                        self?.onSelectListError(error: error)
                    }
                )
            }
        }
    }
}

// MARK: - Business Logic

extension ConfirmTransferSceneViewModel {
    func onSelectListError(error: Error) {
        switch error {
        case let error as TransferAmountCalculatorError:
            switch error {
            case let .insufficientBalance(asset):
                isPresentingSheet = .info(.insufficientBalance(asset, image: AssetViewModel(asset: asset).assetImage))
            case let .insufficientNetworkFee(asset, required):
                isPresentingSheet = .info(.insufficientNetworkFee(asset, image: AssetViewModel(asset: asset).assetImage, required: required, action: onSelectBuy))
            case let .minimumAccountBalanceTooLow(asset, required):
                isPresentingSheet = .info(.accountMinimalBalance(asset, required: required))
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

extension ConfirmTransferSceneViewModel {
    private func onStateChange(state: StateViewType<TransactionInputViewModel>) {
        switch state {
        case .data(let data):
            if case .failure(let error) = data.transferAmount {
                onSelectListError(error: error)
            }
        case .error(let error as TransferAmountCalculatorError):
            onSelectListError(error: error)
        case .error, .loading, .noData:
            break
        }
    }

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
            let metadata = try confirmService.getMetadata(wallet: wallet, data: data)
            try TransferAmountCalculator().validateNetworkFee(metadata.feeAvailable, feeAssetId: metadata.feeAssetId)

            let transferTransactionData = try await confirmService.loadTransferTransactionData(
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
            try await confirmService.executeTransfer(input: input)
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
        TransferAmountCalculator().validate(input: TransferAmountInput(
            asset: dataModel.asset,
            assetBalance: assetBalance,
            value: dataModel.data.value,
            availableValue: availableValue,
            assetFee: dataModel.asset.feeAsset,
            assetFeeBalance: assetFeeBalance,
            fee: fee,
            transferData: data
        ))
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
    private var senderLink: BlockExplorerLink { confirmService.getExplorerLink(chain: dataModel.chain, address: senderAddress) }
    private var feeAssetAddress: AssetAddress { AssetAddress(asset: dataModel.asset.feeAsset, address: senderAddress)}
    private var confirmButtonIcon: Image? {
        guard !state.isError, state.value?.transferAmount?.isSuccess ?? false,
              let auth = try? confirmService.getPasswordAuthentication(),
              let systemName = KeystoreAuthenticationViewModel(authentication: auth).authenticationImage
        else { return nil }
        return Image(systemName: systemName)
    }
}
