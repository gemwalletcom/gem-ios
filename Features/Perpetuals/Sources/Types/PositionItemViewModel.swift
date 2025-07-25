// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import PrimitivesComponents
import Style
import SwiftUI

public struct PositionItemViewModel {
    public let position: PerpetualPosition
    public let perpetual: Perpetual
    public let asset: Asset
    public var action: ((ListAssetItemAction) -> Void)?
    
    public init(position: PerpetualPosition, perpetual: Perpetual, asset: Asset) {
        self.position = position
        self.perpetual = perpetual
        self.asset = asset
    }
    
    public var positionViewModel: PerpetualPositionViewModel {
        PerpetualPositionViewModel(position: position)
    }
}

extension PositionItemViewModel: Identifiable {
    public var id: String { position.id }
}

extension PositionItemViewModel: ListAssetItemViewable {
    public var showBalancePrivacy: Binding<Bool> { .constant(false) }
    
    public var name: String { perpetual.name }
    
    public var symbol: String? { nil }
    
    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: perpetual.assetId).assetImage
    }
    
    public var subtitleView: ListAssetItemSubtitleView {
        .type(
            TextValue(
                text: positionViewModel.positionTypeText,
                style: TextStyle(font: .footnote, color: positionViewModel.positionTypeColor)
            )
        )
    }
    
    public var rightView: ListAssetItemRightView {
        .balance(
            balance: TextValue(
                text: positionViewModel.marginAmountText,
                style: TextStyle(font: .body, color: .primary, fontWeight: .semibold)
            ),
            totalFiat: TextValue(
                text: positionViewModel.pnlWithPercentText,
                style: TextStyle(font: .footnote, color: positionViewModel.pnlColor)
            )
        )
    }
}