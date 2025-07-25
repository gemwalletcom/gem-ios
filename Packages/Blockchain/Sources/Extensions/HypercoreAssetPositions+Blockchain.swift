// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension HypercoreAssetPositions {
    public func mapToPerpetualPositions(walletId: String) -> [PerpetualPosition] {
        assetPositions.compactMap { assetPosition in
            let position = assetPosition.position
            let positionId = "\(walletId)_\(position.coin)"
            let provider = PerpetualProvider.hypercore
            let perpetualId = "\(provider.rawValue)_\(position.coin)"
            
            guard let _ = mapHypercoreCoinToAssetId(position.coin) else {
                return nil
            }
            
            let rawFunding = Float(position.cumFunding.allTime) ?? 0
            let positionSize = Double(position.szi) ?? 0
            
            let fundingValue = positionSize > 0 ? -rawFunding : rawFunding
            let direction: PerpetualDirection = positionSize >= 0 ? .long : .short
            
            return PerpetualPosition(
                id: positionId,
                perpetualId: perpetualId,
                size: Double(position.szi) ?? 0,
                sizeValue: Double(position.positionValue) ?? 0,
                leverage: UInt8(position.leverage.value),
                entryPrice: Double(position.entryPx ?? ""),
                liquidationPrice: Double(position.liquidationPx ?? ""),
                marginType: position.leverage.type == .cross ? .cross : .isolated,
                direction: direction,
                marginAmount: Double(position.marginUsed) ?? 0,
                takeProfit: nil,
                stopLoss: nil,
                pnl: Double(position.unrealizedPnl) ?? 0,
                funding: fundingValue
            )
        }
    }
}
