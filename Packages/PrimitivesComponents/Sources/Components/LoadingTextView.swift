// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization

public struct LoadingTextView: View {
    @Binding var isAnimating: Bool
    
    public init(isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
    }
    
    public var body: some View {
        HStack {
            Text(Localized.Common.loading + "...")
            ActivityIndicator(isAnimating: $isAnimating, style: .medium)
        }
    }
}