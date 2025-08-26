// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct ProviderListItemView: View {
    private let model: ProviderListItemViewModel
    
    public init(model: ProviderListItemViewModel) {
        self.model = model
    }
    
    public var body: some View {
        ListItemImageView(
            title: model.title,
            subtitle: model.subtitle
        )
    }
}