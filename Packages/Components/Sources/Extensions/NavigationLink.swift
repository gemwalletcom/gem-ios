// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension NavigationLink where Label == SwiftUI.EmptyView, Destination == SwiftUI.EmptyView {
    static var empty: NavigationLink {
        NavigationLink(destination: SwiftUI.EmptyView(), label: { SwiftUI.EmptyView() })
    }
}
