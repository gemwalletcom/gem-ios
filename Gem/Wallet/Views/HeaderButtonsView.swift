// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components

typealias HeaderButtonAction = ((HeaderButtonType) -> Void)

struct HeaderButtonsView: View {
    
    let buttons: [HeaderButton]
    var action: HeaderButtonAction?
    
    var maxWidth: CGFloat {
        buttons.count > 3 ? 78 : 88
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(buttons) { button in
                RoundButton(title: button.title, image: button.image) {
                    action?(button.type)
                }
                .frame(maxWidth: maxWidth)
                .disabled(button.isDisabled)
            }
        }
    }
}
