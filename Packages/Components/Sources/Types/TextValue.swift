// Copyright (c). Gem Wallet. All rights reserved.

import Style

public struct TextValue {
    public let text: String
    public let style: TextStyle
    public let lineLimit: Int?
    
    public init(text: String, style: TextStyle, lineLimit: Int? = nil) {
        self.text = text
        self.style = style
        self.lineLimit = lineLimit
    }
}
