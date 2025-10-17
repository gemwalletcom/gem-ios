// Copyright (c). Gem Wallet. All rights reserved.

import Style
import SwiftUI

public struct TextValue {
    public let text: String
    public let style: TextStyle
    public let lineLimit: Int?
    public let truncationMode: Text.TruncationMode
    
    public init(text: String, style: TextStyle, lineLimit: Int? = nil, truncationMode: Text.TruncationMode = .tail) {
        self.text = text
        self.style = style
        self.lineLimit = lineLimit
        self.truncationMode = truncationMode
    }
}
