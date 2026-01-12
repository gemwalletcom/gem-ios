// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization

public struct PinnedSectionHeader: View {
    public static var title: String { Localized.Common.pinned }
    public static var image: Image { Images.System.pin }

    public init() {}

    public var body: some View {
        SectionHeaderView(
            title: Self.title,
            image: Self.image
        )
    }
}
