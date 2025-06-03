// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct SwapChevronView: View {
    init() {}

    var body: some View {
        Images.Actions.receive
            .colorMultiply(Colors.gray)
            .frame(width: 12, height: 12)
            .opacity(0.8)
    }
}
