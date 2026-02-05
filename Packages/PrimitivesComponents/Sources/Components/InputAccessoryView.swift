// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct InputAccessoryView<Item: SuggestionViewable>: View {
    private let isEditing: Bool
    private let suggestions: [Item]
    private let onSelect: (Item) -> Void
    private let onDone: () -> Void
    private let button: StateButton

    public init(
        isEditing: Bool,
        suggestions: [Item],
        onSelect: @escaping (Item) -> Void,
        onDone: @escaping () -> Void,
        button: StateButton
    ) {
        self.isEditing = isEditing
        self.suggestions = suggestions
        self.onSelect = onSelect
        self.onDone = onDone
        self.button = button
    }

    public var body: some View {
        if isEditing {
            SuggestionsAccessoryView(
                suggestions: suggestions,
                onSelect: onSelect,
                onDone: onDone
            )
            .padding(.small)
        } else {
            button
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .padding(.bottom, Spacing.scene.bottom)
        }
    }
}
