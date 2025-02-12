// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public struct SearchableSelectableListView<ViewModel: SelectableListAdoptable & ItemFilterable, Content: View>: View {
    public typealias ListContent = (ViewModel.Item) -> Content
    public typealias FinishSelection = (([ViewModel.Item]) -> Void)

    @Binding private var model: ViewModel

    private let onFinishSelection: FinishSelection?
    private let listContent: ListContent

    public init(
        model: Binding<ViewModel>,
        onFinishSelection: FinishSelection? = nil,
        listContent: @escaping ListContent
    ) {
        _model = model
        self.listContent = listContent
        self.onFinishSelection = onFinishSelection
    }

    public var body: some View {
        SearchableListView(
            items: model.items,
            filter: model.filter(_:query:),
            content: { item in
                if model.isMultiSelectionEnabled {
                    SelectionView(
                        value: item,
                        selection: model.selectedItems.contains(item) ? item : nil,
                        action: onSelect(item:),
                        content: {
                            listContent(item)
                        }
                    )
                } else {
                    NavigationCustomLink(with: listContent(item)) {
                        onSelect(item: item)
                    }
                }
            },
            emptyContent: {
                if let title = model.noResultsTitle {
                    StateEmptyView(
                        title: title,
                        image: model.noResultsImage
                    )
                }
            }
        )
    }

    private func onSelect(item: ViewModel.Item) {
        model.toggle(item: item)
        guard !model.isMultiSelectionEnabled else { return }
        onFinishSelection?(Array(model.selectedItems))
    }
}
