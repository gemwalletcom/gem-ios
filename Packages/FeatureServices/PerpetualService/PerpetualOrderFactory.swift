// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import Formatters

public struct PerpetualOrderFactory {
    private enum OrderAction {
        case open
        case close
    }

    private let formatter = PerpetualPriceFormatter()

    public init() {}

    public func makeOpenOrder(
        perpetual: PerpetualTransferData,
        usdcAmount: BigInt,
        usdcDecimals: Int,
        slippage: Double = 2.0
    ) -> PerpetualConfirmData {
        let slippagePrice = calculateSlippagePrice(
            marketPrice: perpetual.price,
            direction: perpetual.direction,
            action: .open,
            slippage: slippage
        )

        let usdAmount = Double(usdcAmount) / pow(10.0, Double(usdcDecimals))
        let sizeAsAsset = (usdAmount * Double(perpetual.leverage)) / perpetual.price

        return makePerpetualConfirmData(
            direction: perpetual.direction,
            baseAsset: perpetual.baseAsset,
            assetIndex: Int32(perpetual.assetIndex),
            provider: perpetual.provider,
            slippagePrice: slippagePrice,
            sizeAsDouble: sizeAsAsset,
            fiatValue: perpetual.price * sizeAsAsset,
            assetDecimals: Int(perpetual.asset.decimals)
        )
    }

    public func makeCloseOrder(
        assetIndex: Int32,
        perpetual: Perpetual,
        position: PerpetualPosition,
        asset: Asset,
        baseAsset: Asset,
        slippage: Double = 2.0
    ) -> PerpetualConfirmData {
        let positionPrice = calculateSlippagePrice(
            marketPrice: perpetual.price,
            direction: position.direction,
            action: .close,
            slippage: slippage
        )

        return makePerpetualConfirmData(
            direction: position.direction,
            baseAsset: baseAsset,
            assetIndex: assetIndex,
            provider: perpetual.provider,
            slippagePrice: positionPrice,
            sizeAsDouble: abs(position.size),
            fiatValue: abs(position.size) * positionPrice,
            assetDecimals: Int(asset.decimals)
        )
    }
    
    // MARK: - Private methods

    private func calculateSlippagePrice(
        marketPrice: Double,
        direction: PerpetualDirection,
        action: OrderAction,
        slippage: Double
    ) -> Double {
        let slippageFraction = slippage / 100.0
        let multiplier: Double = switch (direction, action) {
        case (.long, .open): 1.0 + slippageFraction
        case (.long, .close): 1.0 - slippageFraction
        case (.short, .open): 1.0 - slippageFraction
        case (.short, .close): 1.0 + slippageFraction
        }
        return marketPrice * multiplier
    }

    private func makePerpetualConfirmData(
        direction: PerpetualDirection,
        baseAsset: Asset,
        assetIndex: Int32,
        provider: PerpetualProvider,
        slippagePrice: Double,
        sizeAsDouble: Double,
        fiatValue: Double,
        assetDecimals: Int
    ) -> PerpetualConfirmData {
        let price = formatter.formatPrice(
            provider: provider,
            slippagePrice,
            decimals: assetDecimals
        )

        let size = formatter.formatSize(
            provider: provider,
            sizeAsDouble,
            decimals: assetDecimals
        )

        return PerpetualConfirmData(
            direction: direction,
            baseAsset: baseAsset,
            assetIndex: assetIndex,
            price: price,
            fiatValue: fiatValue,
            size: size
        )
    }
}
