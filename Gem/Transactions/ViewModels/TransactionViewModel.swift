// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import SwiftUI
import Style
import GemstonePrimitives
import BigInt
import Localization

struct TransactionViewModel {
    let transaction: TransactionExtended
    private let formatter: ValueFormatter
 
    init(
        transaction: TransactionExtended,
        formatter: ValueFormatter
    ) {
        self.transaction = transaction
        self.formatter = formatter
    }
    
    var assetImage: AssetImage {
        let asset = AssetIdViewModel(assetId: transaction.transaction.assetId).assetImage
        return AssetImage(
            type: asset.type,
            imageURL: asset.imageURL,
            placeholder: asset.placeholder,
            chainPlaceholder: overlayImage
        )
    }
    
    var chainAssetImage: AssetImage {
        return AssetIdViewModel(assetId: transaction.transaction.assetId.chain.assetId).assetImage
    }
    
    var overlayImage: Image? {
        switch transaction.transaction.type {
        case .transfer:
            switch transaction.transaction.direction {
            case .incoming:
                return Images.Transaction.incoming
            case .outgoing, .selfTransfer:
                return Images.Transaction.outgoing
            }
        case .swap,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRewards,
            .stakeRedelegate,
            .stakeWithdraw,
            .assetActivation:
            return .none
        }
    }

    var title: String {
        switch transaction.transaction.type {
        case .transfer:
            switch transaction.transaction.state {
            case .confirmed: switch transaction.transaction.direction {
            case .incoming: Localized.Transaction.Title.received
            case .outgoing, .selfTransfer: Localized.Transaction.Title.sent
            }
            case .failed, .pending, .reverted:
                Localized.Transfer.title
            }
        case .swap: Localized.Wallet.swap
        case .tokenApproval: Localized.Transfer.Approve.title
        case .stakeDelegate: Localized.Transfer.Stake.title
        case .stakeUndelegate: Localized.Transfer.Unstake.title
        case .stakeRedelegate: Localized.Transfer.Redelegate.title
        case .stakeRewards: Localized.Transfer.Rewards.title
        case .stakeWithdraw: Localized.Transfer.Withdraw.title
        case .assetActivation: Localized.Transfer.ActivateAsset.title
        }
    }
    
    var titleTextStyle: TextStyle {
        TextStyle(font: Font.system(.body, weight: .medium), color: .primary)
    }
    
    var titleTag: String? {
        switch transaction.transaction.state {
        case .confirmed: .none
        case .pending, .failed, .reverted: TransactionStateViewModel(state: transaction.transaction.state).title
        }
    }
    
    var titleTagType: TitleTagType {
        switch transaction.transaction.state {
        case .confirmed: .none
        case .pending: .progressView()
        case .failed, .reverted: .none //TODO Image
        }
    }
    
    var titleTagStyle: TextStyle {
        let model = TransactionStateViewModel(state: transaction.transaction.state)
        return TextStyle(
            font: Font.system(.footnote, weight: .medium),
            color: model.color,
            background: model.background
        )
    }
    
    
    var titleExtra: String? {
        let chain = transaction.transaction.assetId.chain
        switch transaction.transaction.type {
        case .transfer, .tokenApproval:
            switch transaction.transaction.direction {
            case .incoming:
                return String(
                    format: "%@ %@", 
                    Localized.Transfer.from,
                    AddressFormatter(address: transaction.transaction.from, chain: chain).value()
                )
            case .outgoing, .selfTransfer:
                return String(
                    format: "%@ %@",
                    Localized.Transfer.to,
                    AddressFormatter(address: transaction.transaction.to, chain: chain).value()
                )
            }
        case .stakeDelegate,
            .stakeRedelegate:
            return String(
                format: "%@ %@",
                Localized.Transfer.to,
                AddressFormatter(address: transaction.transaction.to, chain: chain).value()
            )
        case .stakeUndelegate:
            return String(
                format: "%@ %@",
                Localized.Transfer.from,
                AddressFormatter(address: transaction.transaction.to, chain: chain).value()
            )
        case .swap,
            .stakeRewards,
            .stakeWithdraw,
            .assetActivation:
            return .none
        }
    }
    
    var titleTextStyleExtra: TextStyle {
        TextStyle(font: Font.system(.footnote), color: .secondary)
    }
    
    var amount: Double  {
        do {
            return try formatter.double(from: transaction.transaction.valueBigInt, decimals: transaction.asset.decimals.asInt)
        } catch {
            return .zero
        }
    }
    
    var amountSymbolText: String {
        return formatter.string(
            transaction.transaction.valueBigInt,
            decimals: transaction.asset.decimals.asInt,
            currency: transaction.asset.symbol
        )
    }
    
    var networkFeeText: String {
        return formatter.string(transaction.transaction.feeBigInt, decimals: transaction.feeAsset.decimals.asInt)
    }
    
    var networkFeeAmount: Double {
        do {
            return try formatter.double(from: transaction.transaction.feeBigInt, decimals: transaction.feeAsset.decimals.asInt)
        } catch {
            return .zero
        }
    }
    
    var networkFeeSymbolText: String {
        String(format: "%@ %@",
            networkFeeText,
            transaction.feeAsset.symbol
        )
    }
    
    var subtitle: String? {
        switch transaction.transaction.type {
        case .transfer:
            switch transaction.transaction.direction {
            case .incoming:
                return String(format: "+%@", amountSymbolText)
            case .outgoing:
                return String(format: "-%@", amountSymbolText)
            case .selfTransfer:
                return amountSymbolText
            }
        case .stakeRewards, .stakeWithdraw:
            return String(format: "+%@", amountSymbolText)
        case .stakeDelegate, .stakeUndelegate, .stakeRedelegate:
            return amountSymbolText
        case .swap:
            switch transaction.transaction.metadata {
            case .null, .none:
                return .none
            case .swap(let metadata):
                guard let asset = transaction.assets.first(where: { $0.id == metadata.toAsset }) else {
                    return .none
                }
                return "+" + swapFormatter(asset: asset, value: BigInt(stringLiteral: metadata.toValue))
            }
        case .tokenApproval, .assetActivation:
            return transaction.asset.symbol
        }
    }
    
    var subtitleTextStyle: TextStyle {
        switch transaction.transaction.type {
        case .transfer,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeWithdraw,
            .assetActivation:
            switch transaction.transaction.direction {
            case .incoming:
                return TextStyle(font: Font.system(.callout, weight: .semibold), color: Colors.green)
            case .outgoing, .selfTransfer:
                return TextStyle(font: Font.system(.callout, weight: .semibold), color: Colors.black)
            }
        case .stakeRewards,
            .swap:
            return TextStyle(font: Font.system(.callout, weight: .semibold), color: Colors.green)
        }
    }
    
    func swapFormatter(asset: Asset, value: BigInt) -> String {
        return formatter.string(value, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var subtitleExtra: String? {
        switch transaction.transaction.type {
        case .transfer,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw,
            .assetActivation:
            return .none
        case .swap:
            switch transaction.transaction.metadata {
            case .null, .none:
                return .none
            case .swap(let metadata):
                guard let asset = transaction.assets.first(where: { $0.id == metadata.fromAsset }) else {
                    return .none
                }
                return "-" + swapFormatter(asset: asset, value: BigInt(stringLiteral: metadata.fromValue))
            }
        }
    }
    
    var subtitleExtraStyle: TextStyle {
        .footnote
    }
    
    var participant: String {
        switch transaction.transaction.direction {
        case .incoming:
            return transaction.transaction.from
        case .outgoing, .selfTransfer:
            return transaction.transaction.to
        }
    }
    
    private var addressLink: BlockExplorerLink {
        ExplorerService.main.addressUrl(chain: transaction.transaction.assetId.chain, address: participant)
    }
    
    var viewOnAddressExplorerText: String {
        return Localized.Transaction.viewOn(addressLink.name)
    }
    
    var addressExplorerUrl: URL {
        return addressLink.url
    }
    
    private var transactionLink: BlockExplorerLink {
        ExplorerService.main.transactionUrl(chain: transaction.transaction.assetId.chain, hash: transaction.transaction.hash)
    }
    
    var viewOnTransactionExplorerText: String {
        return Localized.Transaction.viewOn(transactionLink.name)
    }
    
    var transactionExplorerUrl: URL {
        return transactionLink.url
    }
}
