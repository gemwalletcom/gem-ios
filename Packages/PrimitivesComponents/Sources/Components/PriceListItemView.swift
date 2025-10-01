// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components

public struct PriceListItemView: View {
    
    let model: PriceListItemViewModel
    
    public init(model: PriceListItemViewModel) {
        self.model = model
    }
 
    public var body: some View {
        HStack {
            ListItemView(title: model.title)
            
            if model.showAmount {
                Spacer()
                
                HStack(spacing: .tiny) {
                    Text(model.priceAmount.text)
                        .textStyle(model.priceAmount.style)
                    Text(model.priceChangeView.text)
                        .textStyle(model.priceChangeView.style)
                }
                .numericTransition(for: [model.priceAmount.text, model.priceChangeView.text])
            }
        }
    }
}
