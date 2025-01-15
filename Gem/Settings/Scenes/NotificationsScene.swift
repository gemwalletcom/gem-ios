// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

struct NotificationsScene: View {
    @State private var model: NotificationsViewModel

    init(model: NotificationsViewModel) {
        _model = State(initialValue: model)
    }
    
    var body: some View {
        List {
            Toggle(
                model.title,
                isOn: $model.isEnabled
            )
            .toggleStyle(AppToggleStyle())
        }
        .onChange(of: model.isEnabled) { (_, newValue) in
            Task {
                try await model.enable(isEnabled: newValue)
            }
        }
        .navigationTitle(model.title)
    }
}
