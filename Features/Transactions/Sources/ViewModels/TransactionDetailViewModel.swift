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
public final class TransactionDetailViewModel: Identifiable {
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
            currency: preferences.currency
        )
        self.preferences = preferences
        transactionExtended = transaction
        request = TransactionRequest(walletId: walletId, transactionId: transaction.id)
    }
    public var id: String { model.transaction.id }

    var title: String { model.titleTextValue.text }
    var networkField: String { Localized.Transfer.network }
    var dateField: String { Localized.Transaction.date }
    var swapAgain: String { Localized.Transaction.swapAgain }

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
            case .incoming: Localized.Transaction.sender
            case .outgoing, .selfTransfer: Localized.Transaction.recipient
            }
        case .tokenApproval, .smartContractCall: Localized.Asset.contract
        case .stakeDelegate: Localized.Stake.validator
        default: .none
        }
    }

    var participant: String? {
        switch model.transaction.transaction.type {
        case .transfer, .transferNFT, .tokenApproval, .smartContractCall, .stakeDelegate:
            model.participant
        default:
            .none
        }
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
            assetImage: nil
        )
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
        case .swap: false
        default: true
        }
    }

    var showSwapAgain: Bool {
        switch headerType {
        case .swap: true
        default: false
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

    func onChangeTransaction(old: TransactionExtended?, new: TransactionExtended?) {
        if old != new, let new {
            model = TransactionViewModel(
                explorerService: ExplorerService.standard,
                transaction: new,
                currency: preferences.currency
            )
        }
    }
}

// MARK: - Actions

extension TransactionDetailViewModel {
    func onSelectTransactionHeader() {
        let url: URL? = switch model.transaction.transaction.metadata {
        case .null, .nft, .none, .perpetual: .none
        case let .swap(metadata): DeepLink.swap(metadata.fromAsset, metadata.toAsset).localUrl
        }

        if let headerLink = url {
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
            state: model.transaction.transaction.state
        )
    }

    func addressLink(account: SimpleAccount) -> BlockExplorerLink {
        model.addressLink(account: account)
    }
}

extension TransactionDetailViewModel {
    var sections: [TransactionSection] {
        [
            .swapAction(
                [.swapAgainButton]
            ),
            .details(
                [.date, .status, .sender, .recipient, .validator, .contract, .memo, .provider, .network, .fee]
            ),
            .explorer(
                [.explorerLink]
            )
        ]
            .filterItems(shouldShow)
            .compactMap { $0 }
    }
    
    private func shouldShow(_ item: TransactionListItem) -> Bool {
        switch item {
        case .date, .status, .network, .fee, .explorerLink:  return true
        case .sender: return model.transaction.transaction.direction == .incoming && participantAccount != nil
        case .recipient: return [.outgoing, .selfTransfer].contains(model.transaction.transaction.direction) && participantAccount != nil
        case .validator: return model.transaction.transaction.type == .stakeDelegate && participant != nil
        case .contract: return [.tokenApproval, .smartContractCall].contains(model.transaction.transaction.type) && participant != nil
        case .memo: return memo != nil
        case .provider:
            if let metadata = model.transaction.transaction.metadata,
               case let .swap(metadata) = metadata {
                return metadata.provider != nil
            }
            return false
        case .swapAgainButton: return showSwapAgain
        }
    }
    
    func model(for item: TransactionListItem) -> ListItemViewModelRepresentable? {
        guard shouldShow(item) else { return nil }
        
        switch item {
        case .status:
            return StatusListItemViewModel(
                state: model.transaction.transaction.state,
                assetImage: model.assetImage,
                infoAction: onStatusInfo
            )
            
        case .sender, .recipient, .validator, .contract:
            guard let title = participantField,
                  let account = participantAccount else { return nil }
            return AddressListItemViewModel(
                title: title,
                account: account,
                mode: .nameOrAddress,
                addressLink: addressLink(account: account)
            )
            
        case .memo:
            return memo
            
        case .fee:
            return FeeListItemViewModel(
                feeDisplay: model.infoModel.feeDisplay,
                onInfo: onNetworkFeeInfo
            )
            
        case .provider:
            guard
                let metadata = model.transaction.transaction.metadata,
                case let .swap(metadata) = metadata,
                let providerId = metadata.provider
            else {
                return nil
            }
            return ProviderListItemViewModel(providerId: providerId)
            
        case .date,
                .network,
                .explorerLink,
                .swapAgainButton:
            return .none
        }
    }
}
