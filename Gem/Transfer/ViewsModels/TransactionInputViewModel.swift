// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Blockchain
import BigInt
import Primitives
import GemstonePrimitives
import PrimitivesComponents
import Store
import Preferences
import NFT

struct TransactionInputViewModel {
    let data: TransferData
    let input: TransactionLoad?
    let metaData: TransferDataMetadata?
    let transferAmountResult: TransferAmountResult?

    private let preferences: Preferences
    private let valueFormatter = ValueFormatter(style: .full)
    private let networkFeeFormatter = ValueFormatter(style: .medium)

    init(
        data: TransferData,
        input: TransactionLoad?,
        metaData: TransferDataMetadata?,
        transferAmountResult: TransferAmountResult?,
        preferences: Preferences = Preferences.standard
    ) {
        self.input = input
        self.data = data
        self.metaData = metaData
        self.transferAmountResult = transferAmountResult
        self.preferences = preferences
    }

    var dataModel: TransferDataViewModel {
        TransferDataViewModel(data: data)
    }

    var asset: Asset {
        data.type.asset
    }
    
    var feeAsset: Asset {
        asset.feeAsset
    }
    
    var value: BigInt {
        switch transferAmountResult {
        case .amount(let amount): amount.value
        case .error(let amount, _): amount.value
        case .none: data.value
        }
    }
    
    var feeValue: BigInt? {
        switch transferAmountResult {
        case .amount(let amount): amount.networkFee
        case .error(let amount, _): amount.networkFee
        case .none: .none
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
        return PriceViewModel(
            price: price,
            currencyCode: preferences.currency
        ).fiatAmountText(amount: fiatValue * price.price)
    }
    
    var headerType: TransactionHeaderType {
        switch data.type {
        case .transfer,
            .generic,
            .stake:
            return TransactionHeaderType.amount(title: amountText, subtitle: amountSecondText)
        case .transferNft(let asset):
            return .nft(name: asset.name, image: NFTAssetViewModel(asset: asset).assetImage)
        case .account(_, let type):
            switch type {
            case .activate: return TransactionHeaderType.amount(title: asset.symbol, subtitle: .none)
            }
        case .tokenApprove:
            return TransactionHeaderType.amount(title: amountText, subtitle: amountSecondText)
        case .swap(let fromAsset, let toAsset, let quote, _):
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
//        case .approval:
//            return TransactionHeaderType.amount(title: asset.symbol, subtitle: amountSecondText)
        }
    }
}
