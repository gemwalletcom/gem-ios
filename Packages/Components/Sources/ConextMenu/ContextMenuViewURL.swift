// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct ContextMenuViewURL: View {
    private let title: String
    private let url: URL
    private let image: String

    public init(title: String, url: URL, image: String) {
        self.title = title
        self.url = url
        self.image = image
    }

    public var body: some View {
        Button(
            action: {
                UIApplication.shared.open(url)
            },
            label: {
                Text(title)
                Image(systemName: image)
            }
        )
    }
}
