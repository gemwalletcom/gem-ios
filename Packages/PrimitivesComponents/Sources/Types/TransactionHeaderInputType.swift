// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public enum TransactionHeaderInputType: Sendable {
    public struct SwapContext: Sendable {
        let assets: [Asset]
        let prices: [String: Price]
        let metadata: TransactionSwapMetadata

        public init(assets: [Asset], prices: [String : Price], metadata: TransactionSwapMetadata) {
            self.prices = prices
            self.metadata = metadata
            self.assets = assets
        }

        public init(assets: [Asset], assetPrices: [AssetPrice], metada: TransactionSwapMetadata) {
            let prices: [String: Price] = assetPrices
                .reduce(into: [String: Price]()) { result, price in
                    if let assetId = try? AssetId(id: price.assetId) {
                        result[assetId.identifier] = Price(
                            price: price.price,
                            priceChangePercentage24h: price.priceChangePercentage24h
                        )
                    }
                }
            self.init(
                assets: assets,
                prices: prices,
                metadata: metada
            )
        }

        var fromValue: BigInt {
            BigInt(stringLiteral: metadata.fromValue)
        }

        var toValue: BigInt {
            BigInt(stringLiteral: metadata.toValue)
        }

        var fromAsset: Asset? {
            assets.first(where: { $0.id == metadata.fromAsset })
        }

        var toAsset: Asset? {
            assets.first(where: { $0.id == metadata.toAsset })
        }

        var fromPrice: Price? {
            prices[metadata.fromAsset.identifier]
        }

        var toPrice: Price? {
            prices[metadata.toAsset.identifier]
        }

        var swapMetadata: SwapMetadata? {
            guard let fromAsset, let toAsset else { return .none }
            return SwapMetadata(
                fromAsset: fromAsset,
                fromValue: fromValue,
                fromPrice: fromPrice,
                toAsset: toAsset,
                toValue: toValue,
                toPrice: toPrice
            )
        }
    }

    public struct SwapMetadata: Sendable {
        let fromAsset: Asset
        let fromValue: BigInt
        let fromPrice: Price?

        let toAsset: Asset
        let toValue: BigInt
        let toPrice: Price?

        public init(fromAsset: Asset, fromValue: BigInt, fromPrice: Price?, toAsset: Asset, toValue: BigInt, toPrice: Price?) {
            self.fromAsset = fromAsset
            self.fromValue = fromValue
            self.fromPrice = fromPrice
            self.toAsset = toAsset
            self.toValue = toValue
            self.toPrice = toPrice
        }
    }

    case amount(showFiatSubtitle: Bool)
    case nft(NFTAsset)
    case swap(SwapMetadata)
}
