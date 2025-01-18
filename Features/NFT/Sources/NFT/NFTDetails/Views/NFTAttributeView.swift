// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Style
import Localization


public struct NFTAttributeView: View {
    private let spacing = Spacing.small
    
    let attributes: [NFTAttribute]
    
    @State private var totalHeight = CGFloat.zero

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            if !attributes.isEmpty {
                Text(Localized.Nft.properties)
                    .textStyle(.subheadline)
            }
            gridView
        }
    }
    
    private var gridView: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return VStack {
            GeometryReader { g in
                ZStack(alignment: .topLeading) {
                    ForEach(self.attributes, id: \.self) { attribute in
                        PropertyView(title: attribute.name, value: attribute.value)
                            .padding([.horizontal, .vertical], Spacing.tiny)
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width) {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if attribute == self.attributes.last! {
                                    width = 0
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: {d in
                                let result = height
                                if attribute == self.attributes.last! {
                                    height = 0
                                }
                                return result
                            })
                    }
                }.background(viewHeightReader($totalHeight))
            }
        }
        .frame(height: totalHeight)
    }

    private struct PropertyView: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.tiny) {
                Text(title.uppercased())
                    .textStyle(.caption)
                    .lineLimit(1)
                
                Text(value)
                    .textStyle(.body)
                    .lineLimit(1)
            }
            .padding(Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Colors.secondaryText, lineWidth: 1)
            )
        }
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

#Preview {
    NFTAttributeView(attributes: [
        .init(name: "Background", value: "Deep Space"),
        .init(name: "Body", value: "Blue"),
        .init(name: "Clothes", value: "Yellow Fuzzy Sweater"),
        .init(name: "Eyes", value: "Baby Toon"),
        .init(name: "Hats ", value: "Red Bucket Hat"),
        .init(name: "Mouth", value: "Stoked")
    ])
}
