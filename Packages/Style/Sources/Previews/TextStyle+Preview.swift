// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

/*
 That is temporary solution to have ability watch previews via xcode.
 Curretly xcode can't recognize shared colors. Gem uses colors from Assets.
 This extension is same TextStyle, but with apple colors instead of Colors struct from Style

 [Do not use this TextStyle outside previews of Packages, this colors only for shared packages]
 */

public extension TextStyle {
    enum Preview {
        public static let title = TextStyle(font: .title, color: .primary)
        public static let headline = TextStyle(font: .headline, color: .primary)
        public static let subheadline = TextStyle(font: .subheadline, color: .secondary)
        public static let body = TextStyle(font: .body, color: .primary)
        public static let callout = TextStyle(font: .callout, color: .primary)
        public static let calloutSecondary = TextStyle(font: .callout, color: .secondary)
        public static let footnote = TextStyle(font: .footnote, color: .secondary)
        public static let caption = TextStyle(font: .caption, color: .secondary)
        public static let largeTitle = TextStyle(font: .largeTitle, color: .primary)
        public static let boldTitle = TextStyle(font: .title.bold(), color: .primary)
        public static let highlighted = TextStyle(font: .headline, color: .white, background: Colors.blue)
    }
}
