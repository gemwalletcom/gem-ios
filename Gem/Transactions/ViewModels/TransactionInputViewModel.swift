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
    let transferAmountResult: TransferAmountResult?

    private let valueFormatter = ValueFormatter(style: .full)
    private let networkFeeFormatter = ValueFormatter(style: .medium)

    init(
        data: TransferData,
        input: TransactionPreload?,
        metaData: TransferDataMetadata?,
        transferAmountResult: TransferAmountResult?
    ) {
        self.input = input
        self.data = data
        self.metaData = metaData
        self.transferAmountResult = transferAmountResult
    }

    var dataModel: TransferDataViewModel {
        TransferDataViewModel(data: data)
    }

    var asset: Asset {
        dataModel.asset
    }
    
    var feeAsset: Asset {
        dataModel.asset.feeAsset
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

    var amountText: String {
        valueFormatter.string(value, decimals: asset.decimals.asInt, currency: asset.symbol)
    }
    
    var amountSecondText: String {
        fiatAmountText(price: metaData?.assetPrice, value: value, decimals: asset.decimals.asInt) ?? ""
    }
    
    var networkFeeText: String? {
        if let feeValue {
            return networkFeeFormatter.string(feeValue, decimals: feeAsset.decimals.asInt, currency: feeAsset.symbol)
        }
        return .none
    }
    
    var networkFeeFiatText: String? {
        if let feeValue {
            return fiatAmountText(price: metaData?.feePrice, value: feeValue, decimals: feeAsset.decimals.asInt)
        }
        return .none
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
            case .swap(let quote, _):
                let formatter = ValueFormatter(style: TransactionHeaderType.swapValueFormatterStyle)
                let fromValue = BigInt(stringLiteral: quote.fromValue)
                let toValue = BigInt(stringLiteral: quote.toValue)
                
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
