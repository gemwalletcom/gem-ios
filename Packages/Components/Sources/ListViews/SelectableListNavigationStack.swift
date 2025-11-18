// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public protocol SelectableListNavigationAdoptable {
    var title: String { get }
    var doneTitle: String { get }
}

public struct SelectableListNavigationStack<ViewModel: SelectableListAdoptable & SelectableListNavigationAdoptable, Content: View>: View {
    public typealias ListContent = (ViewModel.Item) -> Content
    public typealias FinishSelection = (([ViewModel.Item]) -> Void)
    
    @Environment(\.dismiss) private var dismiss

    private let model: ViewModel

    private let onFinishSelection: FinishSelection?
    private let listContent: ListContent
    
    public init(
        model: ViewModel,
        onFinishSelection: FinishSelection?,
        listContent: @escaping ListContent
    ) {
        self.model = model
        self.onFinishSelection = onFinishSelection
        self.listContent = listContent
    }
    
    public var body: some View {
        NavigationStack {
            SelectableListView(
                model: .constant(model),
                onFinishSelection: onFinishSelection,
                listContent: listContent
            )
            .padding(.bottom, .scene.bottom)
            .contentMargins([.top], .medium, for: .scrollContent)
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetentsForCurrentDeviceSize(expandable: true)
            .presentationBackground(Colors.grayBackground)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(model.doneTitle) {
                        dismiss()
                    }.bold()
                }
            }
        }
    }
}
