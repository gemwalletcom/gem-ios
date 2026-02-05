// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

import SwiftUI

struct StateView<Content: View, T: Hashable & Sendable>: View {
    let state: StateViewType<T>
    let content: (T) -> Content
    let emptyView: AnyView
    let noDataView: AnyView
    let loadingView: AnyView
    let errorView: AnyView

    init(
        state: StateViewType<T>,
        @ViewBuilder content: @escaping (T) -> Content,
        @ViewBuilder emptyView: @escaping () -> AnyView,
        @ViewBuilder noDataView: @escaping () -> AnyView,
        @ViewBuilder loadingView: @escaping () -> AnyView,
        @ViewBuilder errorView: @escaping () -> AnyView
    ) {
        self.state = state
        self.content = content
        self.emptyView = emptyView()
        self.noDataView = noDataView()
        self.loadingView = loadingView()
        self.errorView = errorView()
    }

    var body: some View {
        switch state {
        case .noData:
            noDataView
        case .loading:
            loadingView
        case .data(let model):
            content(model)
        case .error(let error):
            Text("Error: \(error.localizedDescription)")
                .foregroundStyle(.red)
        }
    }
}
