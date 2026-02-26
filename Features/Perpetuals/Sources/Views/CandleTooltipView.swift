// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

struct CandleTooltipView: View {
    let model: CandleTooltipViewModel

    var body: some View {
        VStack(spacing: Spacing.small) {
            VStack(spacing: Spacing.extraSmall) {
                ListItemView(title: model.openTitle, subtitle: model.openValue)
                ListItemView(title: model.highTitle, subtitle: model.highValue)
                ListItemView(title: model.lowTitle, subtitle: model.lowValue)
                ListItemView(title: model.closeTitle, subtitle: model.closeValue)
            }
            Divider()
            VStack(spacing: Spacing.extraSmall) {
                ListItemView(title: model.changeTitle, subtitle: model.changeValue)
                ListItemView(title: model.volumeTitle, subtitle: model.volumeValue)
            }
        }
        .padding(Spacing.small)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.small)
                .stroke(Colors.black.opacity(.opacity8), lineWidth: 1)
        )
        .shadow(color: .black.opacity(.opacity12), radius: Spacing.small, y: Spacing.tiny)
        .fixedSize()
    }
}
