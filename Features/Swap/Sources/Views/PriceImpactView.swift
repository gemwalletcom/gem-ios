// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

public struct PriceImpactView: View {
    private let model: PriceImpactViewModel
    private let infoAction: VoidAction

    public init(model: PriceImpactViewModel, infoAction: VoidAction) {
        self.model = model
        self.infoAction = infoAction
    }

    public var body: some View {
        if let priceImpactValue = model.value {
            ListItemView(
                title: model.priceImpactTitle,
                subtitle: priceImpactValue.value,
                subtitleStyle: TextStyle(
                    font: .callout,
                    color: model.priceImpactColor(for: priceImpactValue.type)
                ),
                infoAction: infoAction
            )
        }
    }
}
