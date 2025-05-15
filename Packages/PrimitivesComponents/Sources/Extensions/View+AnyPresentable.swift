// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

public extension View {
    func sheet<T: Identifiable, Content: View>(
        for type: T.Type,
        presenting data: Binding<IdentifiableWrapper?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View {
        sheet(presenting: data, onDismiss: onDismiss) { wrapper in
            if let typedValue = wrapper.value as? T {
                content(typedValue)
            }
        }
    }
}
