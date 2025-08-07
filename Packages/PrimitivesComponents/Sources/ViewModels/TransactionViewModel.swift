// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Formatters
import Foundation
import GemstonePrimitives
import Localization
import Primitives
import Style
import SwiftUI

public struct TransactionViewModel: Sendable {
    public let transaction: TransactionExtended

    private let explorerService: any ExplorerLinkFetchable
    private let assetImageFormatter = AssetImageFormatter()
    private let currency: String

    public init(
        explorerService: any ExplorerLinkFetchable,
        transaction: TransactionExtended,
        currency: String
    ) {
        self.transaction = transaction
        self.explorerService = explorerService
        self.currency = currency
    }

    public var assetImage: AssetImage {
        switch transaction.transaction.metadata {
        case .null, .swap, .none:
            let asset = AssetIdViewModel(assetId: assetId).assetImage
            return AssetImage(
                type: asset.type,
                imageURL: asset.imageURL,
                placeholder: asset.placeholder,
                chainPlaceholder: overlayImage
            )
        case .nft(let metadata):
            let asset = AssetIdViewModel(assetId: assetId).assetImage
            return AssetImage(
                type: "",
                imageURL: assetImageFormatter.getNFTUrl(for: metadata.assetId),
                placeholder: asset.placeholder,
                chainPlaceholder: overlayImage
            )
        }
    }

    public var overlayImage: Image? {
        switch transaction.transaction.type {
        case .transfer, .transferNFT, .smartContractCall:
            switch transaction.transaction.direction {
            case .incoming: Images.Transaction.incoming
            case .outgoing, .selfTransfer: Images.Transaction.outgoing
            }
        case .swap,
                .tokenApproval,
                .stakeDelegate,
                .stakeUndelegate,
                .stakeRewards,
                .stakeRedelegate,
                .stakeWithdraw,
                .assetActivation,
                .perpetualOpenPosition,
                .perpetualClosePosition: .none
        }
    }

    public var infoModel: TransactionInfoViewModel {
        let direction: TransactionDirection? = switch transaction.transaction.type {
        case .transfer: transaction.transaction.direction
        case .stakeRewards, .stakeWithdraw: .incoming
        default: nil
        }

        return TransactionInfoViewModel(
            currency: currency,
            asset: transaction.asset,
            assetPrice: transaction.price,
            feeAsset: transaction.feeAsset,
            feeAssetPrice: transaction.feePrice,
            value: transaction.transaction.valueBigInt,
            feeValue: transaction.transaction.feeBigInt,
            direction: direction
        )
    }

    public var titleTextValue: TextValue {
        let title: String = switch transaction.transaction.type {
        case .transfer, .transferNFT, .smartContractCall:
            switch transaction.transaction.state {
            case .confirmed:
                switch transaction.transaction.direction {
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
        case .perpetualOpenPosition: "Open Position"
        case .perpetualClosePosition: "Close Position"
        }
        return TextValue(
            text: title,
            style: TextStyle(font: Font.system(.body, weight: .medium), color: .primary)
        )
    }

    public var titleTagType: TitleTagType {
        switch transaction.transaction.state {
        case .confirmed: .none
        case .pending: .progressView()
        case .failed, .reverted: .none // TODO: Image
        }
    }

    public var titleTagTextValue: TextValue? {
        let title: String? = switch transaction.transaction.state {
        case .confirmed: .none
        case .pending, .failed, .reverted: TransactionStateViewModel(state: transaction.transaction.state).title
        }
        let model = TransactionStateViewModel(state: transaction.transaction.state)
        return title.map {
            TextValue(
                text: $0,
                style: TextStyle(
                    font: Font.system(.footnote, weight: .medium),
                    color: model.color,
                    background: model.background
                )
            )
        }
    }

    public var titleExtraTextValue: TextValue? {
        let title: String? = {
            let chain = assetId.chain
            switch transaction.transaction.type {
            case .transfer, .transferNFT, .tokenApproval, .smartContractCall:
                switch transaction.transaction.direction {
                case .incoming:
                    return String(
                        format: "%@ %@",
                        Localized.Transfer.from,
                        getDisplayName(address: transaction.transaction.from, chain: chain)
                    )
                case .outgoing, .selfTransfer:
                    return String(
                        format: "%@ %@",
                        Localized.Transfer.to,
                        getDisplayName(address: transaction.transaction.to, chain: chain)
                    )
                }
            case .stakeDelegate,
                    .stakeRedelegate:
                return String(
                    format: "%@ %@",
                    Localized.Transfer.to,
                    getDisplayName(address: transaction.transaction.to, chain: chain)
                )
            case .stakeUndelegate:
                return String(
                    format: "%@ %@",
                    Localized.Transfer.from,
                    getDisplayName(address: transaction.transaction.to, chain: chain)
                )
            case .swap,
                    .stakeRewards,
                    .stakeWithdraw,
                    .assetActivation,
                    .perpetualOpenPosition,
                    .perpetualClosePosition:
                return .none
            }
        }()

        return title.map {
            TextValue(
                text: $0,
                style: TextStyle(font: Font.system(.footnote), color: .secondary)
            )
        }
    }

    public var subtitleTextValue: TextValue? {
        switch transaction.transaction.type {
        case .transfer, .smartContractCall,
                .stakeRewards, .stakeWithdraw,
                .stakeDelegate, .stakeUndelegate, .stakeRedelegate,
                .perpetualOpenPosition, .perpetualClosePosition,
                .assetActivation:
            return infoModel.amountDisplay(formatter: .short).amount

        case .tokenApproval:
            return AmountDisplay.symbol(asset: transaction.asset).amount
        case .swap:
            if case .swap(let meta) = transaction.transaction.metadata,
               let asset = transaction.assets.first(where: { $0.id == meta.toAsset }) {
                return AmountDisplay.numeric(
                    data: AssetValuePrice(asset: asset, value: BigInt(stringLiteral: meta.toValue), price: nil),
                    style: AmountDisplayStyle(sign: .incoming, formatter: .auto, currencyCode: currency)
                ).amount
            }
            return nil
        case .transferNFT:
            return nil
        }
    }


    var subtitleExtraTextValue: TextValue? {
        if case .swap(let meta) = transaction.transaction.metadata,
           let asset = transaction.assets.first(where: { $0.id == meta.fromAsset }) {
            return AmountDisplay.numeric(
                data: AssetValuePrice(asset: asset, value: BigInt(stringLiteral: meta.fromValue), price: nil),
                style: AmountDisplayStyle(
                    sign: .outgoing,
                    formatter: .auto,
                    currencyCode: currency,
                    textStyle: .footnote
                )
            ).amount
        }
        return nil
    }

    public var participant: String {
        switch transaction.transaction.direction {
        case .incoming: transaction.transaction.from
        case .outgoing, .selfTransfer: transaction.transaction.to
        }
    }

    public var viewOnAddressExplorerText: String { Localized.Transaction.viewOn(addressLink.name) }
    public var viewOnTransactionExplorerText: String { Localized.Transaction.viewOn(transactionLink.name) }

    public var addressExplorerUrl: URL { addressLink.url }
    public var transactionExplorerUrl: URL { transactionLink.url }

    public func getDisplayName(address: String, chain: Chain) -> String {
        if let name = getAddressName(address: address) {
            return name
        }
        return AddressFormatter(address: address, chain: chain).value()
    }

    public func getAddressName(address: String) -> String? {
        if address == transaction.transaction.from {
            return transaction.fromAddress?.name
        }

        if address == transaction.transaction.to {
            return transaction.toAddress?.name
        }

        return .none
    }

    private var transactionLink: BlockExplorerLink {
        let swapProvider: String? = switch transaction.transaction.metadata {
        case .swap(let metadata): metadata.provider
        default: .none
        }
        return explorerService.transactionUrl(
            chain: assetId.chain,
            hash: transaction.transaction.hash,
            swapProvider: swapProvider
        )
    }

    private var addressLink: BlockExplorerLink { explorerService.addressUrl(chain: assetId.chain, address: participant) }
    private var assetId: AssetId { transaction.transaction.assetId }
}
