// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct FooterViewModifier<FooterContent: View>: ViewModifier {
    private let footerContent: () -> FooterContent
    
    public init(@ViewBuilder footerContent: @escaping () -> FooterContent) {
        self.footerContent = footerContent
    }
    
    public func body(content: Content) -> some View {
        VStack(spacing: .medium) {
            content
                .scrollContentBackground(.hidden)
            Spacer()
            footerContent()
        }
        .padding(.bottom, .scene.bottom)
    }
}

public extension View {
    func footerView<FooterContent: View>(
        @ViewBuilder footer: @escaping () -> FooterContent
    ) -> some View {
        modifier(FooterViewModifier(footerContent: footer))
    }
}
