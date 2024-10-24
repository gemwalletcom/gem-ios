// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct InfoSheetModifier: ViewModifier {
    @Binding var type: InfoSheetType?

    func body(content: Content) -> some View {
        content
            .sheet(item: $type) {
                InfoSheet(type: $0)
            }
    }
}

// MARK: - Modifier

extension View {
    public func infoSheet(type: Binding<InfoSheetType?>) -> some View {
        self.modifier(InfoSheetModifier(type: type))
    }
}
