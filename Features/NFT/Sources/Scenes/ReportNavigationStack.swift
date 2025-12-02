// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives

public struct ReportNavigationStack: View {
    @State private var model: ReportNftViewModel

    public init(model: ReportNftViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            ReportSelectReasonScene(model: model)
                .toolbarDismissItem(title: .cancel, placement: .topBarLeading)
                .activityIndicator(isLoading: model.state.isLoading, message: model.progressMessage)
                .navigationDestination(for: ReportReasonViewModel.self) { _ in
                    ReportUserReasonScene(model: model)
                }
        }
        .presentationDetentsForCurrentDeviceSize()
        .presentationBackground(Colors.grayBackground)
    }
}
