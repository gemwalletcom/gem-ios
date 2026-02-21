// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public extension Font {
    enum app {
        /// 72pt regular - Extra large title
        public static let extraLargeTitle: Font = .system(size: 72)

        /// 44pt semibold - Primary input
        public static let display: Font = .system(size: 44, weight: .semibold)

        /// 42pt semibold - Large title
        public static let largeTitle: Font = .system(size: 42, weight: .semibold)

        /// 36pt semibold - Title 1
        public static let title1: Font = .system(size: 36, weight: .semibold)

        /// 22pt medium - Title 2
        public static let title2: Font = .system(size: 22, weight: .medium)

        /// 20pt medium - Title 3
        public static let title3: Font = .system(size: 20, weight: .medium)

        /// 17pt medium - Headline
        public static let headline: Font = .system(size: 17, weight: .medium)

        /// 16pt medium - Body
        public static let body: Font = .system(size: 16, weight: .medium)

        /// 13pt medium - Callout
        public static let callout: Font = .system(size: 13, weight: .medium)

        /// 12pt medium - Footnote
        public static let footnote: Font = .system(size: 12, weight: .medium)

        /// 10pt semibold - Caption
        public static let caption: Font = .system(size: 10, weight: .semibold)

        public enum Widget {
            /// 32pt bold - Price
            public static let title: Font = .system(size: 32, weight: .bold)

            /// 16pt regular - Text
            public static let body: Font = .system(size: 16, weight: .regular)

            /// 16pt semibold - Highlighted
            public static let headline: Font = .system(size: 16, weight: .semibold)

            /// 14pt medium - Row text
            public static let callout: Font = .system(size: 14, weight: .medium)
        }
    }
}
