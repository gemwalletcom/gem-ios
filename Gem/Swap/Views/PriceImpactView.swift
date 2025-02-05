// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct PriceImpactView: View {
    let model: PriceImpactViewModel
    
    var body: some View {
        if let priceImpactValue = model.value() {
            ListItemView(
                title: model.priceImpactTitle,
                subtitle: priceImpactValue.value,
                subtitleStyle: TextStyle(
                    font: .callout,
                    color: model.priceImpactColor(for: priceImpactValue.type)
                )
            )
        }
    }
}
