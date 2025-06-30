// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Primitives

public typealias HeaderButtonAction = @MainActor @Sendable (HeaderButtonType) -> Void

public struct HeaderButtonsView: View {
    private let buttons: [HeaderButton]
    private var action: HeaderButtonAction?

    var maxWidth: CGFloat {
        buttons.count > 3 ? 84 : 94
    }

    public init(
        buttons: [HeaderButton],
        action: HeaderButtonAction? = nil
    ) {
        self.buttons = buttons
        self.action = action
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(buttons) {
                buttonView(for: $0)
            }
        }
    }

    @ViewBuilder
    private func buttonView(for button: HeaderButton) -> some View {
        Group {
            switch button.viewType {
            case .button:
                RoundButton(
                    title: button.title,
                    image: button.image,
                    isEnabled: button.isEnabled
                ) {
                    action?(button.type)
                }
            case let .menuButton(items):
                ActionMenu(items: items) {
                    RoundButton(
                        title: button.title,
                        image: button.image,
                        isEnabled: button.isEnabled,
                        action: {} // action empty, handled by menu
                    )
                }
            }
        }
        .accessibilityIdentifier(button.id)
        .frame(maxWidth: maxWidth, alignment: .center)
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
