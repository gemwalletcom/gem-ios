// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives
import Components

public struct TagsView: View {
    private let model: AssetTagsViewModel
    private let onSelect: (AssetTag?) -> Void

    public init(model: AssetTagsViewModel, onSelect: @escaping (AssetTag?) -> Void) {
        self.model = model
        self.onSelect = onSelect
    }

    public var body: some View {
        if model.items.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: .space4) {
                    ForEach(model.items) {
                        TagChip(
                            model: $0,
                            onSelect: onSelect
                        )
                    }
                }
            }
            .accessibilityIdentifier(.tagsView)
        }
    }
}

public struct TagChip: View {
    private let model: AssetTagViewModel
    private let onSelect: (AssetTag?) -> Void

    public init(model: AssetTagViewModel, onSelect: @escaping (AssetTag?) -> Void) {
        self.model = model
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            onSelect(model.tag)
        } label: {
            HStack(spacing: .tiny + .space2) {
                if let icon = model.image {
                    icon
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(Color.primary.opacity(model.opacity))
                        .frame(width: .image.small, height: .image.small)
                }

                Text(model.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary.opacity(model.opacity))
            }
            .padding(.horizontal, .small)
            .padding(.vertical, .tiny + .space2)
            .background {
                RoundedRectangle(
                    cornerRadius: .space12,
                    style: .continuous
                )
                .fill(Colors.listStyleColor)
                .opacity(model.opacity)
            }

        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(.key(model.id))
    }
}
