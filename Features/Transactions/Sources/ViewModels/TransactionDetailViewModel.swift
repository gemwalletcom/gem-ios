// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import SwiftUI
import Style
import Primitives
import BigInt
import Localization
import PrimitivesComponents
import Store
import Preferences
import ExplorerService
import InfoSheet
import class Gemstone.SwapProviderConfig

struct TransactionDetailViewModel {
    let model: TransactionViewModel

    private let preferences: Preferences

    init(
        model: TransactionViewModel,
        preferences: Preferences = Preferences.standard
    ) {
        self.model = model
        self.preferences = preferences
    }
    
    var title: String { model.title }
    var statusField: String { Localized.Transaction.status }
    var networkField: String { Localized.Transfer.network }
    var networkFeeField: String { Localized.Transfer.networkFee }
    var dateField: String { Localized.Transaction.date }
    var memoField: String { Localized.Transfer.memo }
    
    var providerListItem: ListItemImageValue? {
        guard
            let metadata = model.transaction.transaction.metadata,
            case let .swap( metadata) = metadata,
            let providerId = metadata.provider else {
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
            .assetActivation:
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
            .assetActivation:
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
            mode: .auto(addressStyle: .full),
            explorerService: ExplorerService.standard
        )
    }
    
    var participantAccount: SimpleAccount? {
        guard let participant = participant else {
            return .none
        }
        return SimpleAccount(
            name: .none,
            chain: model.transaction.transaction.assetId.chain,
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
        case .failed, .reverted: .none //TODO:
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
        memo != nil
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
}


extension TransactionDetailViewModel: Identifiable {
    var id: String { model.transaction.id }
}
