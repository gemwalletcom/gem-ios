// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import Formatters
import GemstonePrimitives
import Components

public struct TransactionInfoViewModel: Sendable {
    private let asset: Asset
    private let assetPrice: Price?
    private let value: BigInt
    private let direction: TransactionDirection?

    private let feeAsset: Asset
    private let feeAssetPrice: Price?
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
        feeValue: BigInt?,
        direction: TransactionDirection?
    ) {
        self.currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: currency)
        self.asset = asset
        self.assetPrice = assetPrice
        self.feeAsset = feeAsset
        self.feeAssetPrice = feeAssetPrice
        self.value = value
        self.feeValue = feeValue
        self.direction = direction
    }
    
    public var isZero: Bool {
        value.isZero
    }

    public var amountValueText: String {
        switch direction {
        case .outgoing, .selfTransfer: String(format: "-%@", amountValue)
        case .incoming, .none: amountValue
        }
    }

    public var amountValue: String {
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
                .amount(
                    title: amountValueText,
                    subtitle: showFiat ? amountFiatValueText : .none
                )
        case let .nft(name, id):
                .nft(
                    name: name,
                    image: AssetImage(
                        type: "NFT",
                        imageURL: AssetImageFormatter().getNFTUrl(for: id),
                        placeholder: .none, //TODO Add nft placeholder
                        chainPlaceholder: .none
                    )
                )
        case let .swap(swapInput):
                .swap(
                    from: swapAmountField(input: swapInput.from),
                    to: swapAmountField(input: swapInput.to)
                )
        case .symbol:
                .amount(
                    title: asset.symbol,
                    subtitle: .none
                )
        }
    }
}

extension TransactionInfoViewModel {
    private func swapAmountField(input: AssetValuePrice) -> SwapAmountField  {
        SwapAmountField(
            assetImage: AssetIdViewModel(assetId: input.asset.id).assetImage,
            amount: mediumFormatter.string(
                input.value,
                decimals: input.asset.decimals.asInt,
                currency: input.asset.symbol
            ),
            fiatAmount: formattedFiatText(
                price: input.price,
                value: input.value,
                decimals: input.asset.decimals.asInt)
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
