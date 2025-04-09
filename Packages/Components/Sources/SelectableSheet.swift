// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol SelectableSheetViewable: SelectableListAdoptable, ItemFilterable {
    var title: String { get }
    var cancelButtonTitle: String { get }
    var clearButtonTitle: String { get }
    var doneButtonTitle: String { get }
    var confirmButtonTitle: String? { get }

    var isSearchable: Bool { get }
}

public struct SelectableSheet<ViewModel: SelectableSheetViewable, Content: View>: View {
    public typealias ListContent = (ViewModel.Item) -> Content
    public typealias FinishSelection = (([ViewModel.Item]) -> Void)
    @Environment(\.dismiss) var dismiss

    @State private var model: ViewModel
    private let onFinishSelection: FinishSelection?
    private let listContent: ListContent
    private let onConfirmAction: FinishSelection?

    public init(
        model: ViewModel,
        onFinishSelection: FinishSelection? = nil,
        onConfirm: FinishSelection? = nil,
        listContent: @escaping ListContent
    ) {
        _model = State(initialValue: model)
        self.onFinishSelection = onFinishSelection
        self.onConfirmAction = onConfirm
        self.listContent = listContent
    }

    public var body: some View {
        NavigationStack {
            VStack {
                if model.isSearchable {
                    SearchableSelectableListView(
                        model: $model,
                        onFinishSelection: onFinishSelection,
                        listContent: listContent
                    )
                } else {
                    SelectableListView(
                        model: $model,
                        onFinishSelection: onFinishSelection,
                        listContent: listContent
                    )
                }
                if let confirmButtonTitle = model.confirmButtonTitle, onConfirmAction != nil {
                    Spacer()
                    Button(confirmButtonTitle, action: onConfirm)
                    .frame(maxWidth: .scene.button.maxWidth)
                    .buttonStyle(.blue())
                }
            }
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if model.isMultiSelectionEnabled && !model.selectedItems.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(model.clearButtonTitle, action: onReset)
                            .bold()
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(model.cancelButtonTitle, action: onCancel)
                            .bold()
                    }
                }

                if model.isMultiSelectionEnabled {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(model.doneButtonTitle) {
                            onDone()
                        }
                        .bold()
                    }
                }
            }
        }
    }
}

// MARK: - Actions

extension SelectableSheet {
    private func onCancel() {
        dismiss()
    }

    private func onDone() {
        onFinishSelection?(Array(model.selectedItems))
        dismiss()
    }
    
    private func onConfirm() {
        onConfirmAction?(Array(model.selectedItems))
        dismiss()
    }

    private func onReset() {
        model.reset()
    }
}
