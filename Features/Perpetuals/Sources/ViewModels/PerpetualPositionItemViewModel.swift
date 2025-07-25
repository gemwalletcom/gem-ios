// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents

public struct PerpetualPositionItemViewModel: ListAssetItemViewable {
    
    public let positionViewModel: PerpetualPositionViewModel
    public let perpetual: Perpetual
    public let asset: Asset
    public var action: ((ListAssetItemAction) -> Void)?
    
    public init(
        position: PerpetualPosition,
        perpetual: Perpetual,
        asset: Asset
    ) {
        self.positionViewModel = PerpetualPositionViewModel(position: position)
        self.perpetual = perpetual
        self.asset = asset
    }
    
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

extension PerpetualPositionItemViewModel: Identifiable {
    public var id: String { positionViewModel.id }
}