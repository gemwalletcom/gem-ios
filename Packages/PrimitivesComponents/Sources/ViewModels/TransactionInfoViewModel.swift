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
    
    private let currency: String

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
        self.currency = currency
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

    public var amountDisplay: AmountDisplay {
        .numeric(
            .init(
                data: AssetValuePrice(asset: asset, value: value, price: assetPrice),
                formatting: AmountDisplayFormatting(
                    sign: .init(direction),
                    style: .full,
                    currencyCode: currency,
                    showFiat: true
                )
            )
        )
    }

    public var feeDisplay: AmountDisplay? {
        feeValue.map {
            AmountDisplay.numeric(
                .init(
                    data: AssetValuePrice(asset: feeAsset, value: $0, price: feeAssetPrice),
                    formatting: AmountDisplayFormatting(
                        style: .medium,
                        currencyCode: currency,
                        showFiat: false
                    )
                )
            )
        }
    }

    public func headerType(input: TransactionHeaderInputType) -> TransactionHeaderType {
        switch input {
        case let .amount(showFiat):
            return .amount(
                amountDisplay.withFiatVisibility(showFiat)
            )
        case let .nft(name, id):
            return .nft(
                name: name,
                image: AssetImage(
                    type: "NFT",
                    imageURL: AssetImageFormatter().getNFTUrl(for: id),
                    placeholder: .none,
                    chainPlaceholder: .none
                )
            )

        case let .swap(swapInput):
            return .swap(
                from: swapAmountField(input: swapInput.from),
                to:   swapAmountField(input: swapInput.to)
            )
        case .symbol:
            return .amount(.symbol(.init(symbol: asset.symbol)))
        }
    }
}

extension TransactionInfoViewModel {
    private func swapAmountField(input: AssetValuePrice) -> SwapAmountField  {
        let display = AmountDisplay.numeric(
            .init(
                data: input,
                formatting: .init(
                    style: .auto,
                    currencyCode: currency,
                    showFiat: true
                )
            )
        )
        return SwapAmountField(
            assetImage: AssetIdViewModel(assetId: input.asset.id).assetImage,
            amount: display.amount.text,
            fiatAmount: display.fiat?.text
        )
    }
}
