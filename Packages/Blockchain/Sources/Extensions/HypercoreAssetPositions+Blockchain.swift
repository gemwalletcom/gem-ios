// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension HypercoreAssetPositions {
    public func mapToPerpetualPositions() throws -> [PerpetualPosition] {
        try assetPositions.compactMap { assetPosition in
            let position = assetPosition.position
            let positionId = position.coin
            let provider = PerpetualProvider.hypercore
            let perpetualId = "\(provider.rawValue)_\(position.coin)"
            
            let rawFunding = Float(position.cumFunding.sinceOpen) ?? 0
            let positionSize = Double(position.szi) ?? 0
            
            let direction: PerpetualDirection = positionSize >= 0 ? .long : .short
            
            let fundingValue = switch direction {
            case .long: -rawFunding
            case .short: rawFunding < 0 ? -rawFunding : rawFunding
            }
            
            return PerpetualPosition(
                id: positionId,
                perpetualId: perpetualId,
                assetId: mapHypercoreCoinToAssetId(position.coin),
                size: try Double.from(string: position.szi),
                sizeValue: try Double.from(string: position.positionValue),
                leverage: UInt8(position.leverage.value),
                entryPrice: Double(position.entryPx),
                liquidationPrice: Double(position.liquidationPx ?? ""),
                marginType: position.leverage.type == .cross ? .cross : .isolated,
                direction: direction,
                marginAmount: Double(position.marginUsed) ?? 0,
                takeProfit: nil,
                stopLoss: nil,
                pnl: try Double.from(string: position.unrealizedPnl),
                funding: fundingValue
            )
        }
    }
    
    public func mapToPerpetualBalance() throws -> PerpetualBalance {
        let equity     = try Double.from(string: marginSummary.accountValue)
        let marginUsed = try Double.from(string: crossMarginSummary.totalMarginUsed)

        let reserved  = min(max(marginUsed, 0), max(equity, 0))
        let available = max(equity - reserved, 0)
        let withdrawable = try Double.from(string: self.withdrawable)

        return PerpetualBalance(
            available: available,
            reserved: reserved,
            withdrawable: withdrawable
        )
    }
}
