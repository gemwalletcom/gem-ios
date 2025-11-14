// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension View {
    @ViewBuilder
    func tabViewBottomAccessoryIfAvailable<Content: View>(isVisible: Bool, @ViewBuilder content: @escaping () -> Content) -> some View {
        if #available(iOS 26, *), isVisible {
            tabViewBottomAccessory(content: content)
        } else {
            self
        }
    }
}
