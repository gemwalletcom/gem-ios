// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct SwapChevronView: View {
    init() {}

    var body: some View {
        Images.System.chevronDown
            .font(.system(.body, weight: .medium))
            .foregroundStyle(Colors.gray)
    }
}
