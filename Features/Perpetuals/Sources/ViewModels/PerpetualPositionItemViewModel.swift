// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents

struct PerpetualPositionItemViewModel: ListAssetItemViewable {
    
    let model: PerpetualPositionViewModel
    var action: ((ListAssetItemAction) -> Void)?
    
    init(
        model: PerpetualPositionViewModel
    ) {
        self.model = model
    }

    var name: String { model.symbolText }
    var symbol: String? { nil }
    
    var assetImage: AssetImage {
        model.assetImage
    }
    
    var subtitleView: ListAssetItemSubtitleView {
        .type(
            TextValue(
                text: model.positionTypeText,
                style: TextStyle(font: .footnote, color: model.positionTypeColor)
            )
        )
    }
    
    var rightView: ListAssetItemRightView {
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
    var id: String { model.id }
}
