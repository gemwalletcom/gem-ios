// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization

public struct SwapDetailsListView: View {
    private let model: SwapDetailsViewModel
    
    public init(model: SwapDetailsViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack {
            ListItemView(title: Localized.Common.details)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: .tiny) {
                if let rate = model.rateText {
                    HStack(spacing: .zero) {
                        Text(rate)
                            .textStyle(.calloutSecondary)
                        if model.shouldShowPriceImpactInDetails, let value = model.priceImpactValue {
                            Text(value)
                                .textStyle(model.priceImpactModel.priceImpactStyle)
                        }
                    }
                }
                ListItemView(subtitle: model.providerText)
            }
        }
    }
}
