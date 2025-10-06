// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct HeaderNavigationLinkView<Destination: Hashable>: View {
    private let title: String
    private let destination: Destination

    public init(title: String, destination: Destination) {
        self.title = title
        self.destination = destination
    }

    public var body: some View {
        NavigationLink(value: destination) {
            HStack {
                Text(title)
                Images.System.chevronRight
                Spacer()
            }
            .foregroundColor(Colors.gray)
            .bold()
        }
    }
}
