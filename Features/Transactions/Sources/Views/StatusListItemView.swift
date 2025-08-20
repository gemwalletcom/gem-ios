// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct StatusListItemView: View {
    private let model: StatusListItemViewModel
    
    init(model: StatusListItemViewModel) {
        self.model = model
    }
    
    var body: some View {
        HStack(spacing: Spacing.small) {
            ListItemView(
                title: model.title,
                subtitle: model.value,
                subtitleStyle: model.style,
                infoAction: model.infoAction
            )
            if model.showProgress {
                LoadingView(tint: Colors.orange)
            }
        }
    }
}