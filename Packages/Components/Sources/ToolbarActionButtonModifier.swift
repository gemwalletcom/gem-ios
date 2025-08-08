// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

private struct ToolbarActionButtonModifier: ViewModifier {
    private let button: StateButton
    
    init(button: StateButton) {
        self.button = button
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    button
                        .frame(maxWidth: .scene.button.maxWidth)
                        .frame(minHeight: .scene.button.accessoryHeight)
                }
            }
    }
}

public extension View {
    func toolbarActionButton(_ button: StateButton) -> some View {
        modifier(ToolbarActionButtonModifier(button: button))
    }
}
