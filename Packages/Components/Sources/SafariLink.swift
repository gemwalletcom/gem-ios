// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SafariServices
import SwiftUI

public struct SafariLink<Content: View>: View {
    let url: URL
    let content: () -> Content

    @State private var isPresented = false

    public init(url: URL, @ViewBuilder content: @escaping () -> Content) {
        self.url = url
        self.content = content
    }

    public var body: some View {
        Button(action: {
            isPresented = true
        }) {
            content()
        }
        .sheet(isPresented: $isPresented) {
            SFSafariView(url: url)
        }
    }
}
