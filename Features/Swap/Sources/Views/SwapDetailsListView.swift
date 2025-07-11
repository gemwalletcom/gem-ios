// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

public struct SwapDetailsListView: View {
    private let model: SwapDetailsViewModel
    
    public init(model: SwapDetailsViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack {
            ListItemView(title: "Details")
            
            Spacer()
            
            VStack {
                if let rate = model.rateText {
                    ListItemRotateView(
                        title: .empty,
                        subtitle: rate,
                        action: nil
                    )
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
