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
            
            VStack(spacing: .tiny) {
                if let rate = model.rateText {
                    ListItemView(subtitle: rate)
                }
                ListItemImageView(
                    title: nil,
                    subtitle: model.providerText,
                    assetImage: model.providerImage
                )
            }
        }
    }
}
