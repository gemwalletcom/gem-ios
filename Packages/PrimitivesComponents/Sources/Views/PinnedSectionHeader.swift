// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization

public struct PinnedSectionHeader: View {
    public init() {}

    public var body: some View {
        SectionHeaderView(
            title: Localized.Common.pinned,
            image: Images.System.pin
        )
    }
}
