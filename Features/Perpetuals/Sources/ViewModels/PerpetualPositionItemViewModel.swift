// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents
import Formatters

public struct PerpetualPositionItemViewModel: ListAssetItemViewable {
    public let position: PerpetualPosition
    public let perpetual: Perpetual
    
    public init(position: PerpetualPosition, perpetual: Perpetual) {
        self.position = position
        self.perpetual = perpetual
    }
    
    public var showBalancePrivacy: Binding<Bool> { .constant(false) }
    public var name: String { perpetual.name }
    public var symbol: String? { nil }
    public var action: ((ListAssetItemAction) -> Void)?
    
    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: perpetual.asset_id).assetImage
    }
    
    public var subtitleView: ListAssetItemSubtitleView {
        .type(
            TextValue(
                text: positionTypeText,
                style: TextStyle(font: .footnote, color: positionTypeColor)
            )
        )
    }
    
    public var rightView: ListAssetItemRightView {
        .balance(
            balance: TextValue(
                text: positionValueText,
                style: TextStyle(font: .body, color: .primary, fontWeight: .semibold)
            ),
            totalFiat: TextValue(
                text: pnlText,
                style: TextStyle(font: .footnote, color: pnlColor)
            )
        )
    }
    
    // MARK: - Private
    
    private var positionTypeText: String {
        let leverageText = "\(Int(position.leverage))x"
        let direction = position.size > 0 ? "Long" : "Short"
        return "\(direction) \(leverageText)"
    }
    
    private var positionTypeColor: Color {
        position.size > 0 ? Colors.green : Colors.red
    }
    
    private var positionValueText: String {
        let value = abs(position.size) * perpetual.price
        let formatter = CurrencyFormatter(type: .currency)
        return formatter.string(value)
    }
    
    public var pnlPercent: Double {
        let positionValue = abs(position.size) * perpetual.price
        let margin = positionValue / Double(position.leverage)
        guard margin > 0 else { return 0 }
        return (position.pnl / margin) * 100
    }
    
    private var pnlText: String {
        let formatter = CurrencyFormatter(type: .currency)
        let pnlAmount = formatter.string(abs(position.pnl))
        let pnlPercent = pnlPercent
        let pnlPercentText = String(format: "%.1f%%", abs(pnlPercent))
        
        if pnlPercent >= 0 {
            return "+\(pnlAmount) (+\(pnlPercentText))"
        } else {
            return "-\(pnlAmount) (\(pnlPercentText))"
        }
    }
    
    private var pnlColor: Color {
        position.pnl >= 0 ? Colors.green : Colors.red
    }
}

extension PerpetualPositionItemViewModel: Identifiable {
    public var id: String { position.id }
}
