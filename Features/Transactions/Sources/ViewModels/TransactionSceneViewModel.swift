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
public final class TransactionSceneViewModel {
    private let preferences: Preferences
    private let explorerService: ExplorerService

    var request: TransactionRequest
    var transactionExtended: TransactionExtended

    var isPresentingShareSheet = false
    var isPresentingInfoSheet: InfoSheetType? = .none

    public init(
        transaction: TransactionExtended,
        walletId: String,
        preferences: Preferences = Preferences.standard,
        explorerService: ExplorerService = ExplorerService.standard
    ) {
        self.preferences = preferences
        self.explorerService = explorerService
        self.transactionExtended = transaction
        self.request = TransactionRequest(walletId: walletId, transactionId: transaction.id)
    }

    var title: String { model.titleTextValue.text }
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
             .perpetualOpenPosition,
             .perpetualClosePosition:
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
             .perpetualOpenPosition,
             .perpetualClosePosition:
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
            addressLink: model.addressLink(account: account)
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
        model.infoModel.feeDisplay?.amount.text ?? ""
    }

    var networkFeeFiatText: String? {
        model.infoModel.feeDisplay?.fiat?.text
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
        let metadata: TransactionExtendedMetadata? = {
            guard let metadata = model.transaction.transaction.metadata else {
                return .none
            }
            return TransactionExtendedMetadata(
                assets: model.transaction.assets,
                assetPrices: model.transaction.prices,
                transactionMetadata: metadata
            )
        }()
        return TransactionHeaderTypeBuilder.build(
            infoModel: model.infoModel,
            transaction: model.transaction.transaction,
            metadata: metadata
        )
    }

    func onChangeTransaction(_ oldValue: TransactionExtended, _ newValue: TransactionExtended) {
        if oldValue != newValue {
            transactionExtended = newValue
        }
    }
}

extension TransactionSceneViewModel: @preconcurrency Identifiable {
    public var id: String { model.transaction.id }
}

// MARK: - Actions

extension TransactionSceneViewModel {
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

extension TransactionSceneViewModel {
    private var model: TransactionViewModel {
        TransactionViewModel(
            explorerService: ExplorerService.standard,
            transaction: transactionExtended,
            currency: preferences.currency
        )
    }

    private var headerLink: URL? {
        switch model.transaction.transaction.metadata {
        case .null, .nft, .none, .perpetual: .none
        case let .swap(metadata): DeepLink.swap(metadata.fromAsset, metadata.toAsset).localUrl
        }
    }
}
