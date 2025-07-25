// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Style
import SwiftUI
import PrimitivesComponents
import Formatters

public struct PerpetualItemViewModel: ListAssetItemViewable {
    
    private let formatter = CurrencyFormatter(type: .abbreviated)
    
    public let perpetual: Perpetual
    
    public init(perpetual: Perpetual) {
        self.perpetual = perpetual
    }
    
    public var showBalancePrivacy: Binding<Bool> { .constant(false) }
    public var name: String { perpetual.name }
    public var symbol: String? { leverageText }
    public var action: ((ListAssetItemAction) -> Void)?
    
    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: perpetual.assetId).assetImage
    }
    
    public var subtitleView: ListAssetItemSubtitleView {
        .none
    }
    
    public var rightView: ListAssetItemRightView {
        .balance(
            balance: TextValue(
                text: formatter.string(perpetual.volume24h),
                style: TextStyle(font: .body, color: .primary, fontWeight: .semibold)
            ),
            totalFiat: TextValue(
                text: "",
                style: TextStyle(font: .footnote, color: .secondary)
            )
        )
    }
    
    private var leverageText: String {
        guard let maxLeverage = perpetual.leverage.max() else { return "" }
        return "\(maxLeverage)x"
    }
}
