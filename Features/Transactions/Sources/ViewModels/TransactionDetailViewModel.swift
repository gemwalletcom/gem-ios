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

struct TransactionDetailViewModel {
    let model: TransactionViewModel

    private let valueFormatter = ValueFormatter(style: .full)
    private let preferences: Preferences
    private let priceStore: PriceStore

    init(
        model: TransactionViewModel,
        priceStore: PriceStore,
        preferences: Preferences = Preferences.standard
    ) {
        self.model = model
        self.preferences = preferences
        self.priceStore = priceStore
    }
    
    var title: String { model.title }
    var statusField: String { Localized.Transaction.status }
    var networkField: String { Localized.Transfer.network }
    var networkFeeField: String { Localized.Transfer.networkFee }
    var dateField: String { Localized.Transaction.date }
    var memoField: String { Localized.Transfer.memo }

    var priceModel: PriceViewModel {
        PriceViewModel(price: model.transaction.price, currencyCode: preferences.currency)
    }

    var headerType: TransactionHeaderType {
        switch model.transaction.transaction.type {
        case .transfer,
            .tokenApproval,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw,
            .assetActivation,
            .transferNFT,
            .smartContractCall:
            return .amount(title: amountTitle, subtitle: amountSubtitle)
        case .swap:
            switch model.transaction.transaction.metadata {
            case .null, .none:
                fatalError()
            case .swap(let metadata):
                guard
                    let fromAsset = model.transaction.assets.first(where: { $0.id == metadata.fromAsset }),
                    let toAsset = model.transaction.assets.first(where: { $0.id == metadata.toAsset }) else {
                    fatalError()
                }

                let fromValue = model.swapFormatter(asset: fromAsset, value: BigInt(stringLiteral: metadata.fromValue))
                let toValue = model.swapFormatter(asset: toAsset, value: BigInt(stringLiteral: metadata.toValue))

                let prices = (try? priceStore.getPrices(for: model.transaction.assets.map(\.id.identifier))) ?? []
                let fromPrice = prices.first(where: { $0.assetId == fromAsset.id.identifier })?.mapToPrice()
                let toPrice = prices.first(where: { $0.assetId == toAsset.id.identifier })?.mapToPrice()

                let from = SwapAmountField(
                    assetImage: AssetIdViewModel(assetId: fromAsset.id).assetImage,
                    amount: fromValue,
                    fiatAmount: fiatAmountText(
                        price: fromPrice,
                        value: BigInt(stringLiteral: metadata.fromValue),
                        decimals: fromAsset.decimals.asInt
                    )
                )
                let to = SwapAmountField(
                    assetImage: AssetIdViewModel(assetId: toAsset.id).assetImage,
                    amount: toValue,
                    fiatAmount: fiatAmountText(
                        price: toPrice,
                        value: BigInt(stringLiteral: metadata.toValue),
                        decimals: toAsset.decimals.asInt
                    )
                )
                
                return .swap(
                    from: from,
                    to: to
                )
            }
        }
    }
    
    private func fiatAmountText(price: Price?, value: BigInt, decimals: Int) -> String? {
        guard
            let price = price,
            let fiatValue = try? valueFormatter.double(from: value, decimals: decimals) else {
            return .none
        }
        return PriceViewModel(
            price: price,
            currencyCode: preferences.currency
        ).fiatAmountText(amount: fiatValue * price.price)
    }

    var amountTitle: String {
        switch model.transaction.transaction.type {
        case .transfer,
            .transferNFT,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw,
            .smartContractCall:
            return model.amountSymbolText
        case .swap:
            //TODO: Show ETH <> USDT swap info
            return model.amountSymbolText
        case .tokenApproval, .assetActivation:
            return model.transaction.asset.symbol
        }
    }
    
    var amountSubtitle: String? {
        switch model.transaction.transaction.type {
        case .transfer,
            .transferNFT,
            .swap,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw,
            .smartContractCall:
            guard let price = model.transaction.price else {
                return .none
            }
            return priceModel.fiatAmountText(amount: model.amount * price.price)
        case .tokenApproval, .assetActivation:
            return .none
        }
    }
    
    var chain: Chain {
        model.transaction.transaction.assetId.chain
    }
    
    var date: String {
        TransactionDateFormatter(date: model.transaction.transaction.createdAt).row
    }
    
    var participantField: String? {
        switch model.transaction.transaction.type {
        case .transfer, .transferNFT, .tokenApproval, .smartContractCall:
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
            .stakeWithdraw,
            .assetActivation:
            return .none
        }
    }
    
    var participant: String? {
        switch model.transaction.transaction.type {
        case .transfer, .transferNFT, .tokenApproval, .smartContractCall:
            return model.participant
        case .swap,
            .stakeDelegate,
            .stakeUndelegate,
            .stakeRedelegate,
            .stakeRewards,
            .stakeWithdraw,
            .assetActivation:
            return .none
        }
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
        guard let price = model.transaction.feePrice else {
            return .empty
        }
        return priceModel.fiatAmountText(amount: model.networkFeeAmount * price.price)
    }

    var showMemoField: Bool {
        model.transaction.asset.chain.isMemoSupported
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
}

extension TransactionDetailViewModel: Identifiable {
    var id: String { model.transaction.id }
}
