// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives

public struct TransactionInfoViewModel: Sendable {
    private let asset: Asset
    private let assetPrice: Price?

    private let feeAsset: Asset
    private let feeAssetPrice: Price?

    private let value: BigInt
    private let feeValue: BigInt?

    private let fullFormatter = ValueFormatter(style: .full)
    private let mediumFormatter = ValueFormatter(style: .medium)
    private let currencyFormatter: CurrencyFormatter

    public init(
        currency: String,
        asset: Asset,
        assetPrice: Price?,
        feeAsset: Asset,
        feeAssetPrice: Price?,
        value: BigInt,
        feeValue: BigInt?
    ) {
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currency)
        self.asset = asset
        self.assetPrice = assetPrice
        self.feeAsset = feeAsset
        self.feeAssetPrice = feeAssetPrice
        self.value = value
        self.feeValue = feeValue
    }

    public var amountValueText: String {
        fullFormatter.string(
            value,
            decimals: asset.decimals.asInt,
            currency: asset.symbol
        )
    }

    public var amountFiatValueText: String? {
        formattedFiatText(
            price: assetPrice,
            value: value,
            decimals: asset.decimals.asInt
        )
    }

    public var feeValueText: String? {
        if let feeValue {
            return mediumFormatter.string(
                feeValue,
                decimals: feeAsset.decimals.asInt,
                currency: feeAsset.symbol
            )
        }
        return .none
    }

    public var feeFiatValueText: String? {
        if let feeValue {
            return formattedFiatText(
                price: feeAssetPrice,
                value: feeValue,
                decimals: feeAsset.decimals.asInt
            )
        }
        return .none
    }

    public func headerType(input: TransactionHeaderInputType) -> TransactionHeaderType {
        switch input {
        case let .amount(showFiat):
            return .amount(
                title: amountValueText,
                subtitle: showFiat ? amountFiatValueText : .none
            )
        case .nft(let nftAsset):
            return .nft(
                name: asset.name,
                image: NFTAssetViewModel(asset: nftAsset).assetImage
            )
        case .swap(let swapInput):
            let from = swapAmountField(
                asset: swapInput.fromAsset,
                value: swapInput.fromValue,
                price: swapInput.fromPrice
            )
            let to = swapAmountField(
                asset: swapInput.toAsset,
                value: swapInput.toValue,
                price: swapInput.toPrice
            )
            return .swap(
                from: from,
                to: to
            )
        }
    }
}

extension TransactionInfoViewModel {
    private func swapAmountField(asset: Asset, value: BigInt, price: Price?) -> SwapAmountField  {
        SwapAmountField(
            assetImage: AssetIdViewModel(assetId: asset.id).assetImage,
            amount: mediumFormatter.string(
                value,
                decimals: asset.decimals.asInt,
                currency: asset.symbol
            ),
            fiatAmount: formattedFiatText(
                price: price,
                value: value,
                decimals: asset.decimals.asInt)
        )
    }

    private func formattedFiatText(price: Price?, value: BigInt, decimals: Int) -> String? {
        guard
            let price = price,
            let fiatValue = try? fullFormatter.double(from: value, decimals: decimals) else {
            return .none
        }
        return currencyFormatter.string(fiatValue * price.price)
    }
}
