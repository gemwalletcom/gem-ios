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
import SwiftUI
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

    var websiteURL: URL? { dataModel.websiteURL }
    var websiteTitle: String { Localized.Settings.website }

    var senderAddress: String { (try? wallet.account(for: dataModel.chain).address) ?? "" }
    var senderAddressExplorerUrl: URL { senderLink.url }
    var senderExplorerText: String { Localized.Transaction.viewOn(senderLink.name) }

    var progressMessage: String { Localized.Common.loading }

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

    var detailsViewModel: ConfirmDetailsViewModel {
        ConfirmDetailsViewModel(type: data.type, metadata: metadata)
    }
}

// MARK: - ListSectionProvideable

extension ConfirmTransferSceneViewModel: ListSectionProvideable {
    public var sections: [ListSection<ConfirmTransferItem>] {
        [
            ListSection(type: .header, [.header]),
            ListSection(type: .details, [.app, .network, .sender, .recipient, .memo, .details]),
            ListSection(type: .fee, [.networkFee]),
            ListSection(type: .error, [.error])
        ]
    }

    public func itemModel(for item: ConfirmTransferItem) -> any ItemModelProvidable<ConfirmTransferItemModel> {
        switch item {
        case .header:
            ConfirmHeaderViewModel(inputModel: state.value, metadata: metadata, data: data)
        case .app:
            ConfirmAppViewModel(type: data.type)
        case .sender:
            ConfirmSenderViewModel(wallet: wallet)
        case .network:
            ConfirmNetworkViewModel(type: data.type)
        case .recipient:
            ConfirmRecipientViewModel(
                model: dataModel,
                addressName: try? confirmService.getAddressName(chain: dataModel.chain, address: dataModel.recipient.address),
                addressLink: confirmService.getExplorerLink(chain: dataModel.chain, address: dataModel.recipient.address)
            )
        case .memo:
            ConfirmMemoViewModel(type: data.type, recipientData: data.recipientData)
        case .details:
            detailsViewModel
        case .networkFee:
            ConfirmNetworkFeeViewModel(
                state: state,
                title: feeModel.title,
                value: feeModel.value,
                fiatValue: feeModel.fiatValue,
                infoAction: onSelectNetworkFeeInfo
            )
        case .error:
            ConfirmErrorViewModel(
                state: state,
                onSelectListError: onSelectListError
            )
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

    func onSelectPerpetualDetails(_ model: PerpetualDetailsViewModel) {
        isPresentingSheet = .perpetualDetails(model)
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
                #debugLog("preload transaction error: \(error)")
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
            #debugLog("confirm transaction error: \(error)")
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
