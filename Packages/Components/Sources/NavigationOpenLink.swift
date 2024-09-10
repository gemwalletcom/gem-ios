// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI

public struct NavigationOpenLink<Content: View>: View {
    private let url: URL
    private let content: Content

    public init(
        url: URL,
        with content: Content
    ) {
        self.url = url
        self.content = content
    }

    public var body: some View {
        NavigationCustomLink(with: content) {
            UIApplication.shared.open(url)
        }
    }
}
