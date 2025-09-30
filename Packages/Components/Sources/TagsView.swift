// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct TagsView<T: TagItemViewable>: View {
    private let tags: [T]
    private let onSelect: (T) -> Void

    public init(tags: [T], onSelect: @escaping (T) -> Void) {
        self.tags = tags; self.onSelect = onSelect
    }

    public var body: some View {
        if tags.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .small) {
                    ForEach(tags) {
                        TagView(
                            tag: $0,
                            action: onSelect
                        )
                    }
                }
            }
        }
    }
}

public struct TagView<T: TagItemViewable>: View {
    private let tag: T
    private let action: (T) -> Void

    public init(tag: T, action: @escaping (T) -> Void) {
        self.tag = tag; self.action = action
    }

    public var body: some View {
        Button {
            action(tag)
        } label: {
            HStack(spacing: .tiny + .space2) {
                if let image = tag.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: .image.small, height: .image.small)
                }

                Text(tag.title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Color.primary.opacity(tag.opacity))
            .padding(.horizontal, .small)
            .padding(.vertical, .tiny + .space2)
            .background {
                RoundedRectangle(
                    cornerRadius: .space12,
                    style: .continuous
                )
                .fill(Colors.listStyleColor)
                .opacity(tag.opacity)
            }

        }
        .liquidGlass(interactive: false)
    }
}
