// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct DynamicGridViewItem: Equatable, Identifiable, Hashable, Sendable {
    public var id: String = UUID().uuidString
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}

public struct DynamicGridView: View {
    @State private var totalHeight = CGFloat.zero
    
    private let items: [DynamicGridViewItem]
    
    public init(items: [DynamicGridViewItem]) {
        self.items = items
    }

    public var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return VStack {
            GeometryReader { g in
                ZStack(alignment: .topLeading) {
                    ForEach(items) { item in
                        PropertyView(title: item.title, value: item.subtitle)
                            .padding([.trailing, .bottom], Spacing.small)
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width) {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if item == items.last {
                                    width = 0
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: {d in
                                let result = height
                                if item == items.last {
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
