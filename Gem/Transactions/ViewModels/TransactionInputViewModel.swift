// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import BigInt
import Primitives
import GemstonePrimitives

struct TransactionInputViewModel {
    
    let data: TransferData
    let input: TransactionPreload?
    let metaData: TransferDataMetadata?
    let transferAmountResult: TranferAmountResult?

    private let valueFormatter = ValueFormatter(style: .full)
    private let networkFeeFormatter = ValueFormatter(style: .medium)

    init(
        data: TransferData,
        input: TransactionPreload?,
        metaData: TransferDataMetadata?,
        transferAmountResult: TranferAmountResult?
    ) {
        self.input = input
        self.data = data
        self.metaData = metaData
        self.transferAmountResult = transferAmountResult
    }
    
    var asset: Asset {
        data.recipientData.asset
    }
    
    var feeAsset: Asset {
        data.recipientData.asset.feeAsset
    }
    
    var value: BigInt {
        switch transferAmountResult {
        case .amount(let amount):
            return amount.value
        case .error(let amount, _):
            return amount.value
        case .none:
            return data.value
        }
    }
    
    var feeValue: BigInt? {
        switch transferAmountResult {
        case .amount(let amount):
            return amount.networkFee
        case .error(let amount, _):
            return amount.networkFee
        case .none:
            return nil
        }
    }
    
    var address: String {
        if let name = data.recipientData.recipient.name {
            return name
        }
        return data.recipientData.recipient.address
    }
    
    var showMemoField: Bool {
        switch data.type {
        case .transfer:
            return AssetViewModel(asset: data.recipientData.asset).supportMemo
        case .swap, .generic, .stake:
            return false
        }
    }
    
    var memo: String? { data.recipientData.recipient.memo }
    
    var recipient: String? {
        switch data.type {
        case .transfer,
            .swap,
            .generic:
            address
        case .stake(_, let stakeType):
            switch stakeType {
            case .stake(let validator):
                validator.name
            case .unstake(let delegation):
                delegation.validator.name
            case .redelegate(_, let toValidator):
                toValidator.name
            case .withdraw(let delegation):
                delegation.validator.name
            case .rewards:
                .none
            }
        }
    }
    
    var recipientAccount: SimpleAccount {
        SimpleAccount(
            name: recipient,
            chain: data.recipientData.asset.chain,
            address: data.recipientData.recipient.address
        )
    }
    
    var network: String {
        data.recipientData.asset.chain.asset.name
    }
    
    var amountText: String {
        valueFormatter.string(value, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var amountSecondText: String {
        fiatAmountText(price: metaData?.assetPrice, value: value, decimals: asset.decimals.asInt) ?? ""
    }
    
    var networkFeeText: String {
        if let feeValue {
            return networkFeeFormatter.string(feeValue, decimals: feeAsset.decimals.asInt, currency: feeAsset.symbol)
        }
        return ""
    }
    
    var networkFeeFiatText: String? {
        if let feeValue {
            return fiatAmountText(price: metaData?.feePrice, value: feeValue, decimals: feeAsset.decimals.asInt)
        }
        return nil
    }
    
    private func fiatAmountText(price: Price?, value: BigInt, decimals: Int) -> String? {
        guard
            let price = price,
            let fiatValue = try? valueFormatter.double(from: value, decimals: decimals) else {
            return .none
        }
        return PriceViewModel(price: price).fiatAmountText(amount: fiatValue * price.price)
    }
    
    var headerType: TransactionHeaderType {
        switch data.type {
        case .transfer,
            .generic,
            .stake:
            return TransactionHeaderType.amount(title: amountText, subtitle: amountSecondText)
        case .swap(let fromAsset, let toAsset, let action):
            switch action {
            case .swap(let swapData):
                let formatter = ValueFormatter(style: TransactionHeaderType.swapValueFormatterStyle)
                let fromValue = BigInt(stringLiteral: swapData.quote.fromAmount)
                let toValue = BigInt(stringLiteral: swapData.quote.toAmount)
                
                let fromPrice = metaData?.assetPrices[fromAsset.id.identifier]
                let toPrice = metaData?.assetPrices[toAsset.id.identifier]
                
                let from = SwapAmountField(
                    assetImage: AssetIdViewModel(assetId: fromAsset.id).assetImage,
                    amount: formatter.string(fromValue, decimals: fromAsset.decimals.asInt, currency: fromAsset.symbol),
                    fiatAmount: fiatAmountText(price: fromPrice, value: fromValue, decimals: fromAsset.decimals.asInt)
                )
                let to = SwapAmountField(
                    assetImage: AssetIdViewModel(assetId: toAsset.id).assetImage,
                    amount: formatter.string(toValue, decimals: toAsset.decimals.asInt, currency: toAsset.symbol),
                    fiatAmount: fiatAmountText(price: toPrice, value: toValue, decimals: toAsset.decimals.asInt)
                )
                return TransactionHeaderType.swap(from: from, to: to)
            case .approval:
                return TransactionHeaderType.amount(title: amountText, subtitle: amountSecondText)
            }
        }
    }
}
