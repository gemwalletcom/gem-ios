// Copyright (c). Gem Wallet. All rights reserved.
import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct PriceImpactView: View {
    let fromAsset: AssetData
    let fromValue: String
    let toAsset: AssetData
    let toValue: String
    
    let model: PriceImpactViewModel
    
    var body: some View {
        let priceImpactValue = model.priceImpactValue(fromValue: fromValue, toValue: toValue)
        
        switch priceImpactValue {
        case .none, .low:
            EmptyView()
        case .medium(let value):
            ListItemView(
                title: model.priceImpact,
                subtitle: value,
                subtitleStyle: TextStyle(
                    font: .callout,
                    color: Colors.orange
                )
            )
        case .high(let value):
            ListItemView(
                title: model.priceImpact,
                subtitle: value,
                subtitleStyle: TextStyle(
                    font: .callout,
                    color: Colors.red
                )
            )
        case .positive(let value):
            ListItemView(
                title: model.priceImpact,
                subtitle: value,
                subtitleStyle: TextStyle(
                    font: .callout,
                    color: Colors.green
                )
            )
        }
    }
}
