// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListGroupRowStyleModifier: ViewModifier {
    let color: Color

    public func body(content: Content) -> some View {
        content
            .cleanListRow(listRowBackground: color)
    }
}

extension View {
    public func listGroupRowStyle(color: Color = Colors.grayBackground) -> some View {
        self.modifier(ListGroupRowStyleModifier(color: color))
    }
}
