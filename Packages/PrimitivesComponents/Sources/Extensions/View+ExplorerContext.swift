// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

public struct ExplorerContextModifier: ViewModifier {
    @State private var isPresentingUrl: URL?

    let context: ExplorerContextData

    public func body(content: Content) -> some View {
        let copyValue = context.copyValue
        let explorerLink = context.explorerLink
        content
            .contextMenu([
                .copy(value: copyValue.rawValue),
                .url(title: Localized.Transaction.viewOn(explorerLink.name), onOpen: { isPresentingUrl = explorerLink.url })
            ])
            .safariSheet(url: $isPresentingUrl)
    }
}

public extension View {
    func explorerContext(_ context: ExplorerContextData) -> some View {
        modifier(ExplorerContextModifier(context: context))
    }
}
