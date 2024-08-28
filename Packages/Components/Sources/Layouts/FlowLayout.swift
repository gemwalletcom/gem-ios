// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct FlowLayout: Layout {
    var spacing: CGFloat

    public init(spacing: CGFloat = Spacing.small) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes,
                      spacing: spacing,
                      containerWidth: containerWidth).size
    }

    public func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets =
        layout(sizes: sizes,
               spacing: spacing,
               containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: .init(x: offset.x + bounds.minX,
                                    y: offset.y + bounds.minY),
                          proposal: .unspecified)
        }
    }

    private func layout(sizes: [CGSize],
                spacing: CGFloat = 8,
                containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            result.append(currentPosition)
            currentPosition.x += size.width
            maxX = max(maxX, currentPosition.x)
            currentPosition.x += spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (result,
                .init(width: maxX, height: currentPosition.y + lineHeight))
    }
}

// MARK: - Previews

#Preview {
    @State var previews = ["test1", "test2", "test3", "test4", "test5", "test6", "test7", "test8", "test9", "test10"]
    return FlowLayout {
        ForEach(previews, id: \.self) { preview in
            Text(preview)
                .padding(Spacing.medium)
                .background(Color.blue)
                .clipShape(Capsule())
        }
    }
    .padding()

}
