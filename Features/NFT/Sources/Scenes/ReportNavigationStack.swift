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
                .toolbarDismissItem(type: .close, placement: .topBarLeading)
                .activityIndicator(isLoading: model.state.isLoading, message: model.progressMessage)
        }
        .presentationDetentsForCurrentDeviceSize()
        .presentationBackground(Colors.grayBackground)
    }
}
