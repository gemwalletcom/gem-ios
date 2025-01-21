// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style
import Localization
import Components

public struct NFTAttributesView: View {
    private let spacing = Spacing.small
    
    let attributes: [NFTAttribute]
    
    @State private var totalHeight = CGFloat.zero

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text(Localized.Nft.properties)
                .textStyle(.subheadline)
            DynamicGridView(items: attributes.map { DynamicGridViewItem(title: $0.name, subtitle: $0.value)})
        }
    }
}

#Preview {
    NFTAttributesView(attributes: [
        .init(name: "Background", value: "Deep Space"),
        .init(name: "Body", value: "Blue"),
        .init(name: "Clothes", value: "Yellow Fuzzy Sweater"),
        .init(name: "Eyes", value: "Baby Toon"),
        .init(name: "Hats ", value: "Red Bucket Hat"),
        .init(name: "Mouth", value: "Stoked")
    ])
}
