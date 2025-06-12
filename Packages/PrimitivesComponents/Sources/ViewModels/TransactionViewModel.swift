// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import SwiftUI
import Style
import BigInt
import Localization

public struct TransactionViewModel: Sendable {
    public let transaction: TransactionExtended

    private let formatter: ValueFormatter
    private let explorerService: any ExplorerLinkFetchable

    public init(
        explorerService: any ExplorerLinkFetchable,
        transaction: TransactionExtended,
        formatter: ValueFormatter
    ) {
        self.transaction = transaction
        self.formatter = formatter
        self.explorerService = explorerService
    }
    
    public var assetImage: AssetImage {
        let asset = AssetIdViewModel(assetId: assetId).assetImage
        return AssetImage(
            type: asset.type,
            imageURL: asset.imageURL,
            placeholder: asset.placeholder,
            chainPlaceholder: overlayImage
        )
    }
    
    public var chainAssetImage: AssetImage {
        AssetIdViewModel(assetId: assetId.chain.assetId).assetImage
    }
    
    public var overlayImage: Image? {
        switch transaction.transaction.type {
        case .transfer, .transferNFT, .smartContractCall:
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

    public var title: String {
        switch transaction.transaction.type {
        case .transfer, .transferNFT, .smartContractCall:
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

    public var titleTextStyle: TextStyle {
        TextStyle(font: Font.system(.body, weight: .medium), color: .primary)
    }
    
    public var titleTag: String? {
        switch transaction.transaction.state {
        case .confirmed: .none
        case .pending, .failed, .reverted: TransactionStateViewModel(state: transaction.transaction.state).title
        }
    }
    
    public var titleTagType: TitleTagType {
        switch transaction.transaction.state {
        case .confirmed: .none
        case .pending: .progressView()
        case .failed, .reverted: .none //TODO Image
        }
    }
    
    public var titleTagStyle: TextStyle {
        let model = TransactionStateViewModel(state: transaction.transaction.state)
        return TextStyle(
            font: Font.system(.footnote, weight: .medium),
            color: model.color,
            background: model.background
        )
    }
    
    
    public var titleExtra: String? {
        let chain = assetId.chain
        switch transaction.transaction.type {
        case .transfer, .transferNFT, .tokenApproval, .smartContractCall:
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
    
    public var titleTextStyleExtra: TextStyle {
        TextStyle(font: Font.system(.footnote), color: .secondary)
    }
    
    public var amountSymbolText: String {
        formatter.string(
            transaction.transaction.valueBigInt,
            decimals: transaction.asset.decimals.asInt,
            currency: transaction.asset.symbol
        )
    }
    
    public var networkFeeText: String {
        formatter.string(transaction.transaction.feeBigInt, decimals: transaction.feeAsset.decimals.asInt)
    }
    
    public var networkFeeSymbolText: String {
        String(format: "%@ %@",
            networkFeeText,
            transaction.feeAsset.symbol
        )
    }
    
    public var subtitle: String? {
        switch transaction.transaction.type {
        case .transfer, .transferNFT, .smartContractCall:
            guard transaction.transaction.valueBigInt.isZero == false else {
                return amountSymbolText
            }
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
        case .assetActivation:
            return transaction.asset.symbol
        case .tokenApproval:
            if transaction.transaction.value == .zero {
                return [transaction.transaction.value, transaction.asset.symbol].joined(separator: " ")
            } else {
                return transaction.asset.symbol
            }
        }
    }
    
    public var subtitleTextStyle: TextStyle {
        switch transaction.transaction.type {
        case .transfer,
            .transferNFT,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeWithdraw,
            .assetActivation,
            .smartContractCall:
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
    
    public func swapFormatter(asset: Asset, value: BigInt) -> String {
        formatter.string(value, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    public var subtitleExtra: String? {
        switch transaction.transaction.type {
        case .transfer,
            .transferNFT,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw,
            .assetActivation,
            .smartContractCall:
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
    
    public var subtitleExtraStyle: TextStyle { .footnote }

    public var participant: String {
        switch transaction.transaction.direction {
        case .incoming: transaction.transaction.from
        case .outgoing, .selfTransfer: transaction.transaction.to
        }
    }

    public var viewOnAddressExplorerText: String {
        Localized.Transaction.viewOn(addressLink.name)
    }

    public var viewOnTransactionExplorerText: String {
        Localized.Transaction.viewOn(transactionLink.name)
    }

    public var addressExplorerUrl: URL { addressLink.url }
    public var transactionExplorerUrl: URL { transactionLink.url }

    private var assetId: AssetId {
        transaction.transaction.assetId
    }

    private var transactionLink: BlockExplorerLink {
        let swapProvider: String? = switch transaction.transaction.type {
            case .swap: transaction.transaction.metadata?.swap?.provider
            default: .none
        }
        return explorerService.transactionUrl(
            chain: assetId.chain,
            hash: transaction.transaction.hash,
            swapProvider: swapProvider
        )
    }

    private var addressLink: BlockExplorerLink {
        explorerService.addressUrl(chain: assetId.chain, address: participant)
    }
}
