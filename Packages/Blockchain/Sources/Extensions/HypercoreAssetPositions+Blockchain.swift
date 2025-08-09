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
                size: Double(position.szi) ?? 0,
                sizeValue: Double(position.positionValue) ?? 0,
                leverage: UInt8(position.leverage.value),
                entryPrice: Double(position.entryPx),
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
    
    public func mapToPerpetualBalance() throws -> PerpetualBalance {
        let total = try Double.from(string: marginSummary.accountValue)
        let crossMargin = try Double.from(string: crossMarginSummary.totalMarginUsed)
        let withdrawable = try Double.from(string: withdrawable)
        let available = max(total - crossMargin, 0)
    
        return PerpetualBalance(
            available: available,
            reserved: crossMargin,
            withdrawable: withdrawable
        )
    }
}
