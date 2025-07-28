// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import ExplorerService
import Foundation
import class Gemstone.SwapProviderConfig
import InfoSheet
import Localization
import Preferences
import Primitives
import PrimitivesComponents
import Store
import Style
import SwiftUI

@Observable
@MainActor
public final class TransactionDetailViewModel {
    private var model: TransactionViewModel
    private let preferences: Preferences

    var request: TransactionRequest
    var transactionExtended: TransactionExtended?

    var isPresentingShareSheet = false
    var isPresentingInfoSheet: InfoSheetType? = .none

    public init(
        transaction: TransactionExtended,
        walletId: String,
        preferences: Preferences = Preferences.standard
    ) {
        model = TransactionViewModel(
            explorerService: ExplorerService.standard,
            transaction: transaction,
            formatter: .auto
        )
        self.preferences = preferences
        transactionExtended = transaction
        request = TransactionRequest(walletId: walletId, transactionId: transaction.id)
    }

    var title: String { model.title }
    var statusField: String { Localized.Transaction.status }
    var networkField: String { Localized.Transfer.network }
    var networkFeeField: String { Localized.Transfer.networkFee }
    var dateField: String { Localized.Transaction.date }
    var memoField: String { Localized.Transfer.memo }
    var swapAgain: String { Localized.Transaction.swapAgain }

    var providerListItem: ListItemImageValue? {
        guard
            let metadata = model.transaction.transaction.metadata,
            case let .swap(metadata) = metadata,
            let providerId = metadata.provider
        else {
            return .none
        }
        let config = SwapProviderConfig.fromString(id: providerId).inner()

        return ListItemImageValue(
            title: Localized.Common.provider,
            subtitle: config.name,
            assetImage: nil
        )
    }

    var chain: Chain {
        model.transaction.transaction.assetId.chain
    }

    var date: String {
        TransactionDateFormatter(date: model.transaction.transaction.createdAt).row
    }

    var participantField: String? {
        switch model.transaction.transaction.type {
        case .transfer, .transferNFT:
            switch model.transaction.transaction.direction {
            case .incoming:
                return Localized.Transaction.sender
            case .outgoing, .selfTransfer:
                return Localized.Transaction.recipient
            }
        case .tokenApproval, .smartContractCall:
            return Localized.Asset.contract
        case .stakeDelegate:
            return Localized.Stake.validator
        case .swap,
             .stakeUndelegate,
             .stakeRedelegate,
             .stakeRewards,
             .stakeWithdraw,
             .assetActivation,
             .perpetualApproval,
             .perpetualOpenPosition,
             .perpetualClosePosition,
             .perpetualWithdraw:
            return .none
        }
    }

    var participant: String? {
        switch model.transaction.transaction.type {
        case .transfer, .transferNFT, .tokenApproval, .smartContractCall, .stakeDelegate:
            return model.participant
        case .swap,
             .stakeUndelegate,
             .stakeRedelegate,
             .stakeRewards,
             .stakeWithdraw,
             .assetActivation,
             .perpetualApproval,
             .perpetualOpenPosition,
             .perpetualClosePosition,
             .perpetualWithdraw:
            return .none
        }
    }

    var recipientAddressViewModel: AddressListItemViewModel? {
        guard let title = participantField, let account = participantAccount else {
            return .none
        }
        return AddressListItemViewModel(
            title: title,
            account: account,
            mode: .nameOrAddress,
            explorerService: ExplorerService.standard
        )
    }

    var participantAccount: SimpleAccount? {
        guard let participant = participant else {
            return .none
        }
        let name = model.getAddressName(address: participant)
        return SimpleAccount(
            name: name,
            chain: chain,
            address: participant,
            assetImage: .none
        )
    }

    var transactionState: TransactionState {
        model.transaction.transaction.state
    }

    var statusText: String {
        TransactionStateViewModel(state: model.transaction.transaction.state).title
    }

    var statusType: TitleTagType {
        switch model.transaction.transaction.state {
        case .confirmed: .none
        case .failed, .reverted: .none // TODO:
        case .pending: .progressView()
        }
    }

    var statusTextStyle: TextStyle {
        let color: Color = {
            switch model.transaction.transaction.state {
            case .confirmed:
                return Colors.green
            case .pending:
                return Colors.orange
            case .failed, .reverted:
                return Colors.red
            }
        }()
        return TextStyle(font: .callout, color: color)
    }

    var network: String {
        model.transaction.asset.chain.asset.name
    }

    var assetImage: AssetImage {
        AssetIdViewModel(assetId: model.transaction.asset.id).assetImage
    }

    var networkAssetImage: AssetImage {
        AssetIdViewModel(assetId: model.transaction.asset.chain.assetId).networkAssetImage
    }

    var networkFeeText: String {
        model.networkFeeSymbolText
    }

    var networkFeeFiatText: String? {
        infoModel.feeFiatValueText
    }

    var showMemoField: Bool {
        if let memo {
            return memo.isNotEmpty
        }
        return false
    }

    var memo: String? {
        model.transaction.transaction.memo
    }

    var transactionExplorerUrl: URL {
        model.transactionExplorerUrl
    }

    var transactionExplorerText: String {
        model.viewOnTransactionExplorerText
    }

    var showClearHeader: Bool {
        switch headerType {
        case .amount, .nft: true
        case .swap: false
        }
    }

    var showSwapAgain: Bool {
        switch headerType {
        case .amount, .nft: false
        case .swap: true
        }
    }

    var headerType: TransactionHeaderType {
        let swapMetadata: SwapMetadata? = {
            guard let metadata = model.transaction.transaction.metadata, case let .swap(transactionSwapMetadata) = metadata else {
                return .none
            }
            return SwapMetadata(
                assets: model.transaction.assets,
                assetPrices: model.transaction.prices,
                transactionMetadata: transactionSwapMetadata
            )
        }()
        return TransactionHeaderTypeBuilder.build(
            infoModel: infoModel,
            transaction: model.transaction.transaction,
            swapMetadata: swapMetadata
        )
    }

    var infoModel: TransactionInfoViewModel {
        TransactionInfoViewModel(
            currency: preferences.currency,
            asset: model.transaction.asset,
            assetPrice: model.transaction.price,
            feeAsset: model.transaction.feeAsset,
            feeAssetPrice: model.transaction.feePrice,
            value: model.transaction.transaction.valueBigInt,
            feeValue: model.transaction.transaction.feeBigInt,
            direction: model.transaction.transaction.type == .transfer ? model.transaction.transaction.direction : nil
        )
    }

    func onChangeTransaction(old: TransactionExtended?, new: TransactionExtended?) {
        if old != new, let new {
            model = TransactionViewModel(
                explorerService: ExplorerService.standard,
                transaction: new,
                formatter: .auto
            )
        }
    }
}

extension TransactionDetailViewModel: @preconcurrency Identifiable {
    public var id: String { model.transaction.id }
}

// MARK: - Actions

extension TransactionDetailViewModel {
    func onSelectTransactionHeader() {
        if let headerLink = headerLink {
            UIApplication.shared.open(headerLink)
        }
    }

    func onSelectShare() {
        isPresentingShareSheet = true
    }

    func onNetworkFeeInfo() {
        isPresentingInfoSheet = .networkFee(chain)
    }

    func onStatusInfo() {
        isPresentingInfoSheet = .transactionState(
            imageURL: model.assetImage.imageURL,
            placeholder: model.assetImage.placeholder,
            state: transactionState
        )
    }
}

// MARK: - Private

extension TransactionDetailViewModel {
    private var headerLink: URL? {
        switch model.transaction.transaction.metadata {
        case .null, .nft, .none: .none
        case let .swap(metadata): DeepLink.swap(metadata.fromAsset, metadata.toAsset).localUrl
        }
    }
}
