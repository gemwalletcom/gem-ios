// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct AppIconScene: View {
    @State private var model: AppIconSceneViewModel

    public init(model: AppIconSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Section {
                LazyVGrid(columns: model.columns, spacing: .medium) {
                    ForEach(model.icons) { iconModel in
                        AppIconView(
                            model: iconModel,
                            action: { Task { await model.set(iconModel.icon) } }
                        )
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: .medium, leading: .medium, bottom: .space12, trailing: .medium))
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}
