// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import GemstonePrimitives
import SwiftUI
import Style
import Primitives
import BigInt

struct TransactionDetailViewModel {
    let model: TransactionViewModel
    
    var priceModel: PriceViewModel {
        return PriceViewModel(price: model.transaction.price)
    }
    
    var title: String {
        return model.title
    }
    
    var statusField: String { Localized.Transaction.status }
    var networkField: String { Localized.Transfer.network }
    var networkFeeField: String { Localized.Transfer.networkFee }
    var dateField: String { Localized.Transaction.date }
    var memoField: String { Localized.Transfer.memo }
    
    var headerType: TransactionHeaderType {
        switch model.transaction.transaction.type {
        case .transfer,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw:
            return .amount(title: amountTitle, subtitle: amountSubtitle)
        case .swap:
            switch model.transaction.transaction.metadata {
            case .null, .none:
                fatalError()
            case .swap(let metadata):
                let formatter = ValueFormatter(style: TransactionHeaderType.swapValueFormatterStyle)
                guard
                    let fromAsset = model.transaction.assets.first(where: { $0.id == metadata.fromAsset }),
                    let toAsset = model.transaction.assets.first(where: { $0.id == metadata.toAsset }) else {
                    fatalError()
                }
                let fromValue = formatter.string(BigInt(stringLiteral: metadata.fromValue), decimals: fromAsset.decimals.asInt, currency: fromAsset.symbol)
                let toValue = formatter.string(BigInt(stringLiteral: metadata.toValue), decimals: toAsset.decimals.asInt, currency: toAsset.symbol)
                
                let from = SwapAmountField(
                    assetImage: AssetIdViewModel(assetId: fromAsset.id).assetImage,
                    amount: fromValue,
                    fiatAmount: .none
                )
                let to = SwapAmountField(
                    assetImage: AssetIdViewModel(assetId: toAsset.id).assetImage,
                    amount: toValue,
                    fiatAmount: .none
                )
                
                return .swap(
                    from: from,
                    to: to
                )
            }
        }
    }

    var openNetwork: Bool {
        model.transaction.asset.type != .native
    }

    var amountTitle: String {
        switch model.transaction.transaction.type {
        case .transfer, 
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw:
            return model.amountSymbolText
        case .swap:
            //TODO: Show ETH <> USDT swap info
            return model.amountSymbolText
        case .tokenApproval:
            return model.transaction.asset.symbol
        }
    }
    
    var amountSubtitle: String? {
        switch model.transaction.transaction.type {
        case .transfer, 
            .swap,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw:
            guard let price = model.transaction.price else {
                return .none
            }
            return priceModel.fiatAmountText(amount: model.amount * price.price)
        case .tokenApproval:
            return .none
        }
    }
    
    var date: String {
        return TransactionDateFormatter(date: model.transaction.transaction.createdAt).row
    }
    
    var participantField: String? {
        switch model.transaction.transaction.type {
        case .transfer, .tokenApproval:
            switch model.transaction.transaction.direction {
            case .incoming:
                return Localized.Transaction.sender
            case .outgoing, .selfTransfer:
                return Localized.Transaction.recipient
            }
        case .swap,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw:
            return .none
        }
    }
    
    var participant: String? {
        switch model.transaction.transaction.type {
        case .transfer, .tokenApproval:
            return model.participant
        case .swap,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw:
            return .none
        }
    }
    
    var participantAccount: SimpleAccount? {
        guard let participant = participant else {
            return .none
        }
        return SimpleAccount(name: .none, chain: model.transaction.transaction.assetId.chain, address: participant)
    }
    
    var status: String {
        TransactionStateViewModel(state: model.transaction.transaction.state).title
    }
    
    var statusType: TitleTagType {
        switch model.transaction.transaction.state {
        case .confirmed: .none
        case .failed, .reverted: .none //TODO:
        case .pending: .progressView
        }
    }
    
    var statusTextStyle: TextStyle {
        let color: Color = {
            switch model.transaction.transaction.state {
            case .confirmed:
                return TextStyle.calloutSecondary.color
            case .pending:
                return Colors.orange
            case .failed, .reverted:
                return Colors.red
            }
        }()
        return TextStyle(font: .callout, color: color)
    }
    
    var network: String {
        return model.transaction.asset.chain.asset.name
    }
    
    var networkAssetImage: AssetImage {
        return AssetIdViewModel(assetId: model.transaction.asset.chain.assetId).assetImage
    }
    
    var networkFeeText: String {
        return model.networkFeeSymbolText
    }
    
    var networkFeeFiatText: String? {
        guard let price = model.transaction.feePrice else {
            return .empty
        }
        return priceModel.fiatAmountText(amount: model.networkFeeAmount * price.price)
    }
    
    var showMemoField: Bool {
        AssetViewModel(asset: model.transaction.asset).supportMemo
    }
    
    var memo: String? {
        return model.transaction.transaction.memo
    }
    
    var transactionExplorerUrl: URL {
        return model.transactionExplorerUrl
    }
    
    var transactionExplorerText: String {
        return model.viewOnTransactionExplorerText
    }
}

extension TransactionDetailViewModel: Identifiable {
    var id: String { model.transaction.id }
}

