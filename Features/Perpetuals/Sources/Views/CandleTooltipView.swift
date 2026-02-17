// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

struct CandleTooltipView: View {
    let model: CandleTooltipViewModel

    var body: some View {
        VStack(spacing: Spacing.extraSmall) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.extraSmall) {
                    Text(model.openTitle.text)
                        .textStyle(model.openTitle.style)
                    Text(model.openValue.text)
                        .textStyle(model.openValue.style)
                }
                Spacer(minLength: Spacing.medium)
                VStack(alignment: .trailing, spacing: Spacing.extraSmall) {
                    Text(model.closeTitle.text)
                        .textStyle(model.closeTitle.style)
                    Text(model.closeValue.text)
                        .textStyle(model.closeValue.style)
                }
            }
            RangeBarView(model: model.rangeBar)
                .padding(.bottom, Spacing.extraSmall)
            Divider()
                .padding(.bottom, Spacing.extraSmall)
            HStack {
                Text(model.volumeTitle.text)
                    .textStyle(model.volumeTitle.style)
                Spacer()
                Text(model.volumeValue.text)
                    .textStyle(model.volumeValue.style)
            }
        }
        .padding(Spacing.small)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.small)
                .stroke(Colors.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: Spacing.small, y: Spacing.tiny)
        .fixedSize()
    }
}
