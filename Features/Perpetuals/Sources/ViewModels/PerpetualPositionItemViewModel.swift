// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents

public struct PerpetualPositionItemViewModel: ListAssetItemViewable {
    
    public let model: PerpetualPositionViewModel
    public var action: ((ListAssetItemAction) -> Void)?
    
    public init(
        model: PerpetualPositionViewModel
    ) {
        self.model = model
    }
    
    public var showBalancePrivacy: Binding<Bool> { .constant(false) }
    public var name: String { model.symbolText }
    public var symbol: String? { nil }
    
    public var assetImage: AssetImage {
        model.assetImage
    }
    
    public var subtitleView: ListAssetItemSubtitleView {
        .type(
            TextValue(
                text: model.leverageText,
                style: TextStyle(font: .footnote, color: model.positionTypeColor)
            )
        )
    }
    
    public var rightView: ListAssetItemRightView {
        .balance(
            balance: TextValue(
                text: model.marginAmountText,
                style: TextStyle(font: .body, color: .primary, fontWeight: .medium)
            ),
            totalFiat: TextValue(
                text: model.pnlWithPercentText,
                style: TextStyle(font: .footnote, color: model.pnlColor)
            )
        )
    }
}

extension PerpetualPositionItemViewModel: Identifiable {
    public var id: String { model.id }
}
