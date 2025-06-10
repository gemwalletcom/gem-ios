// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct SafariViewModifier: ViewModifier {
    @Binding var url: URL?

    public func body(content: Content) -> some View {
        content
            .sheet(item: $url) { url in
                SFSafariView(url: url)
            }
    }
}

public extension View {
    func safariSheet(url: Binding<URL?>) -> some View {
        modifier(SafariViewModifier(url: url))
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
