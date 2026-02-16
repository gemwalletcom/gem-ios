// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

struct RangeBarView: View {
    let model: RangeBarViewModel

    var body: some View {
        VStack(spacing: Spacing.tiny) {
            HStack {
                Text(model.lowTitle.text).textStyle(model.lowTitle.style)
                Spacer()
                Text(model.highTitle.text).textStyle(model.highTitle.style)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Colors.red, Colors.green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: Spacing.tiny)

                    Circle()
                        .fill(Colors.whiteSolid)
                        .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 1))
                        .frame(width: Spacing.small, height: Spacing.small)
                        .offset(x: max(0, min(geometry.size.width - Spacing.small, geometry.size.width * model.closePosition - Spacing.tiny)))
                }
            }
            .frame(height: Spacing.small)

            HStack {
                Text(model.lowValue.text).textStyle(model.lowValue.style)
                Spacer()
                Text(model.highValue.text).textStyle(model.highValue.style)
            }
        }
    }
}
