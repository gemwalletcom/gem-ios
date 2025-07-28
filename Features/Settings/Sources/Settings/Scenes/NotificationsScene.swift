// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct NotificationsScene: View {
    @State private var model: NotificationsViewModel

    public init(model: NotificationsViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Toggle(
                model.title,
                isOn: $model.isEnabled
            )
            .toggleStyle(AppToggleStyle())
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .onChange(of: model.isEnabled) { (_, newValue) in
            Task {
                try await model.enable(isEnabled: newValue)
            }
        }
        .navigationTitle(model.title)
    }
}
