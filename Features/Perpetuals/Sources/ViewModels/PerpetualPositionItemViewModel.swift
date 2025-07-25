// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents
import Formatters

public struct PerpetualPositionItemViewModel: ListAssetItemViewable {
    private let perpetualViewModel: PerpetualViewModel
    private let positionViewModel: PerpetualPositionViewModel
    
    public init(
        position: PerpetualPosition,
        perpetualData: PerpetualData
    ) {
        self.perpetualViewModel = PerpetualViewModel(perpetual: perpetualData.perpetual)
        self.positionViewModel = PerpetualPositionViewModel(position: position, currencyStyle: .currency)
    }
    
    public var perpetual: Perpetual { perpetualViewModel.perpetual }
    public var showBalancePrivacy: Binding<Bool> { .constant(false) }
    public var name: String { perpetualViewModel.name }
    public var symbol: String? { nil }
    public var action: ((ListAssetItemAction) -> Void)?
    
    public var assetImage: AssetImage {
        perpetualViewModel.assetImage
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
