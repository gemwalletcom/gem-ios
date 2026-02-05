// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization

public struct SuggestionsAccessoryView<Item: SuggestionViewable>: View {

    public let suggestions: [Item]
    public let onSelect: (Item) -> Void
    public let onDone: () -> Void

    public init(
        suggestions: [Item],
        onSelect: @escaping (Item) -> Void,
        onDone: @escaping () -> Void
    ) {
        self.suggestions = suggestions
        self.onSelect = onSelect
        self.onDone = onDone
    }

    public var body: some View {
        HStack {
            ForEach(suggestions) { suggestion in
                Button(action: { onSelect(suggestion) }) {
                    Text(suggestion.title)
                }
                .buttonStyle(.listStyleColor(paddingVertical: .small, cornerRadius: .small))
                .frame(maxWidth: .infinity)
            }

            Button(action: onDone) {
                Text(Localized.Common.done)
            }
            .buttonStyle(.clear)
            .padding(.horizontal, .small)
        }
    }
}
