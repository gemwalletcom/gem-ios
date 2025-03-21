// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives

public struct AssetTagsView: View {
    public let model: AssetTagsViewModel
    public let onSelect: (AssetTag) -> Void
    
    public init(model: AssetTagsViewModel, onSelect: @escaping (AssetTag) -> Void) {
        self.model = model
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: .medium) {
                ForEach(model.items) { tagModel in
                    Button {
                        onSelect(tagModel.tag)
                    } label: {
                        Text(tagModel.title)
                            .padding(.horizontal, .small)
                            .padding(.vertical, .tiny)
                            .textStyle(.subheadline)
                            .background(Colors.listStyleColor)
                            .opacity(!model.hasSelected || tagModel.isSelected ? 1 : 0.35)
                            .cornerRadius(.small)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}
