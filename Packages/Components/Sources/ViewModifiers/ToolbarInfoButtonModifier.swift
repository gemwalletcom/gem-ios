// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct ToolbarInfoButtonModifier: ViewModifier {
    
    @State private var isPresentingUrl: URL?

    private let url: URL
    private let placement: ToolbarItemPlacement
    
    init(
        url: URL,
        placement: ToolbarItemPlacement = .topBarTrailing
    ) {
        self.url = url
        self.placement = placement
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: placement) {
                    Button("", systemImage: SystemImage.info) {
                        isPresentingUrl = url
                    }
                    .accessibilityIdentifier(.safariInfoButton)
                }
            }
            .safariSheet(url: $isPresentingUrl)
    }
}

public extension View {
    func toolbarInfoButton(
        url: URL,
        placement: ToolbarItemPlacement = .topBarTrailing
    ) -> some View {
        modifier(ToolbarInfoButtonModifier(url: url, placement: placement))
    }
}
