// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components

typealias HeaderButtonAction = ((HeaderButtonType) -> Void)

struct HeaderButtonsView: View {
    let buttons: [HeaderButton]
    var action: HeaderButtonAction?
    
    var maxWidth: CGFloat {
        buttons.count > 3 ? 84 : 94
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(buttons) { button in
                RoundButton(
                    title: button.title,
                    image: button.image,
                    isEnabled: button.isEnabled
                ) {
                    action?(button.type)
                }
                .accessibilityIdentifier(button.id)
                .frame(maxWidth: maxWidth, alignment: .center)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let buttons = HeaderButtonType.allCases.map({ HeaderButton(type: $0, isEnabled: true) })
    return VStack {
        Spacer()
        HeaderButtonsView(buttons: buttons, action: nil)
        Spacer()
    }
}
