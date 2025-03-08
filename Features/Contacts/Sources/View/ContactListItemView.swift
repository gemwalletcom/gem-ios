// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct ContactListItemView: View {
    
    public let name: TextValue?
    public let address: TextValue?
    public let description: TextValue?
    
    public init(
        name: String? = nil,
        address: String? = nil,
        description: String? = nil
    ) {
        self.name = name.map { TextValue(text: $0, style: TextStyle.bodyBold) }
        self.address = address.map { TextValue(text: $0, style: TextStyle.caption) }
        self.description = description.map { TextValue(text: $0, style: TextStyle.callout) }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: .tiny) {
            if let name {
                Text(name.text)
                    .textStyle(name.style)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            
            if let description, !description.text.isEmpty {
                Text(description.text)
                    .textStyle(description.style)
                    .lineLimit(3)
                    .truncationMode(.tail)
            }
            
            if let address {
                Text(address.text)
                    .textStyle(address.style)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(.trailing, .small)
    }
}
