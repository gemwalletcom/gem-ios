// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style

typealias HeaderButtonAction = ((HeaderButtonType) -> Void)

struct HeaderButtonsView: View {
    let buttons: [HeaderButton]
    var action: HeaderButtonAction?

    private let maxButtonWidth: CGFloat = Spacing.scene.button.maxWidth
    private let buttonSpacing: CGFloat = Spacing.small

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.extraSmall) {
            ForEach(buttons) { button in
                RoundButton(title: button.title, image: button.image) {
                    action?(button.type)
                }
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
            }
        }
        .frame(maxWidth: Spacing.scene.content.maxWidth)
    }
}

// MARK: - Previews

#Preview {
    let buttons = HeaderButtonType.allCases.map({ HeaderButton(type: $0) })
    return VStack {
        Spacer()
        HeaderButtonsView(buttons: buttons, action: nil)
        Spacer()
    }
}
