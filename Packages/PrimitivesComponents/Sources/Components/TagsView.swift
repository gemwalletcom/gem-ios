// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives
import Components

public struct TagsView: View {
    public let model: AssetTagsViewModel
    public let onSelect: (AssetTag) -> Void
    
    public init(model: AssetTagsViewModel, onSelect: @escaping (AssetTag) -> Void) {
        self.model = model
        self.onSelect = onSelect
    }
    
    public var body: some View {
        if model.items.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: .medium) {
                    ForEach(model.items) { tagModel in
                        Button {
                            onSelect(tagModel.tag)
                        } label: {
                            Text(tagModel.title)
                                .padding(.horizontal, .small)
                                .padding(.vertical, .tiny)
                                .font(.subheadline)
                                .background(Colors.listStyleColor)
                                .foregroundColor(model.foregroundColor(for: tagModel.tag))
                                .cornerRadius(.small)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityIdentifier(.key(tagModel.tag.rawValue))
                    }
                }
            }
            .accessibilityIdentifier(.tagsView)
        }
    }
}
