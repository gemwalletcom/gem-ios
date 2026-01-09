// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Primitives

struct AppIconView: View {
    let model: AppIconViewModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: .tiny) {
                model.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(size: .image.semiLarge)
                    .clipShape(RoundedRectangle(cornerRadius: .space12))
                    .overlay(
                        RoundedRectangle(cornerRadius: .space12)
                            .stroke(model.isSelected ? Colors.blueDark : .clear, lineWidth: .space2)
                    )

                Text(model.displayName)
                    .font(.caption)
                    .foregroundStyle(model.isSelected ? Colors.blue : Colors.secondaryText)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
