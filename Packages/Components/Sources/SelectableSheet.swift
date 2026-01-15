// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public protocol SelectableSheetViewable: SelectableListAdoptable, ItemFilterable {
    var title: String { get }
    var cancelButtonTitle: String { get }
    var clearButtonTitle: String { get }
    var doneButtonTitle: String { get }
    var confirmButtonTitle: String { get }

    var isSearchable: Bool { get }
}

public struct SelectableSheet<ViewModel: SelectableSheetViewable, Content: View>: View {
    public typealias ListContent = (ViewModel.Item) -> Content
    public typealias FinishSelection = ((SelectionResult<ViewModel.Item>) -> Void)
    
    @Environment(\.dismiss) var dismiss

    @State private var model: ViewModel
    private let onFinishSelection: FinishSelection
    private let listContent: ListContent

    public init(
        model: ViewModel,
        onFinishSelection: @escaping FinishSelection,
        listContent: @escaping ListContent
    ) {
        _model = State(initialValue: model)
        self.onFinishSelection = onFinishSelection
        self.listContent = listContent
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    if model.isSearchable {
                        SearchableSelectableListView(
                            model: $model,
                            onFinishSelection: { onFinish(items: $0, isConfirmed: false) },
                            listContent: listContent
                        )
                    } else {
                        SelectableListView(
                            model: $model,
                            onFinishSelection: { onFinish(items: $0, isConfirmed: false) },
                            listContent: listContent
                        )
                    }
                }
                .padding(.bottom, .scene.button.height)
                
                VStack(spacing: .small) {
                    Divider()
                        .frame(height: 1 / UIScreen.main.scale)
                        .background(Colors.grayVeryLight)
                    
                    StateButton(
                        text: model.confirmButtonTitle,
                        action: onConfirm
                    )
                    .frame(maxWidth: .scene.button.maxWidth)
                }
                .background(Colors.grayBackground)
            }
            .padding(.bottom, .scene.bottom)
            .contentMargins(.top, .scene.top, for: .scrollContent)
            .background(Colors.grayBackground)
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                let cancelToolbarItem = {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(model.cancelButtonTitle, action: onCancel)
                            .bold()
                    }
                }
                switch model.selectionType {
                case .multiSelection:
                    if model.selectedItems.isEmpty {
                        cancelToolbarItem()
                    } else {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(model.clearButtonTitle, action: onReset)
                                .bold()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(model.doneButtonTitle) {
                            onDone()
                        }
                        .bold()
                    }
                case .navigationLink, .checkmark:
                    cancelToolbarItem()
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
        onFinish(items: Array(model.selectedItems), isConfirmed: false)
        dismiss()
    }
    
    private func onConfirm() {
        onFinish(items: Array(model.selectedItems), isConfirmed: true)
    }

    private func onReset() {
        model.reset()
    }
    
    private func onFinish(items: [ViewModel.Item], isConfirmed: Bool) {
        let value = SelectionResult(items: items, isConfirmed: isConfirmed)
        onFinishSelection(value)
    }
}
