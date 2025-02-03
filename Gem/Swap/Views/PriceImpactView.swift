// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct PriceImpactView: View {
    let model: PriceImpactViewModel
    
    var body: some View {
        let type = model.type()

        if let value = type.value {
            ListItemView(
                title: model.priceImpactTitle,
                subtitle: value,
                subtitleStyle: TextStyle(
                    font: .callout,
                    color: type.color
                )
            )
        }
    }
}
