// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct TooltipView: View {
    
    public let type: Self.TooltipType
    public let title: String
    public let image: String
    
    public enum TooltipType {
        case regular
    }
    
    public init(type: Self.TooltipType, title: String, image: String) {
        self.type = type
        self.title = title
        self.image = image
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: image)
            Text(title)
                .font(.system(.body, weight: .regular))
        }
        .padding(8)
        .background(Colors.grayVeryLight)
        .cornerRadius(8)
    }
}
