// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components

public struct FeeListItemView: View {
    private let model: FeeListItemViewModel
    
    public init(model: FeeListItemViewModel) {
        self.model = model
    }
    
    public var body: some View {
        ListItemView(
            title: model.title,
            subtitle: model.value,
            subtitleExtra: model.fiat,
            placeholders: model.value == nil ? [.subtitle] : [],
            infoAction: model.onInfo
        )
    }
}
