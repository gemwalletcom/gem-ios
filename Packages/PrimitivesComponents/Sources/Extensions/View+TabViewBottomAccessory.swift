// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension View {
    @ViewBuilder
    func tabViewBottomAccessoryIfAvailable<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        if #available(iOS 26, *) {
            tabViewBottomAccessory(content: content)
        } else {
            self
        }
    }
}
