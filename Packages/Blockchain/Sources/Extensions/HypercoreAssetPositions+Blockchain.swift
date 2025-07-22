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
            
            return PerpetualPosition(
                id: positionId,
                perpetual_id: perpetualId,
                size: Double(position.szi) ?? 0,
                leverage: UInt8(position.leverage.value),
                liquidation_price: Double(position.liquidationPx ?? "") ?? 0,
                margin_type: position.leverage.type == .cross ? .cross : .isolated,
                margin_amount: Double(position.marginUsed) ?? 0,
                take_profit: nil, // Not provided by Hypercore
                stop_loss: nil, // Not provided by Hypercore
                pnl: Double(position.unrealizedPnl) ?? 0,
                funding: Float(position.cumFunding.allTime)
            )
        }
    }
}
