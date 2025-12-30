// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Localization
import Style

public struct RecentsScene: View {
    @Environment(\.dismiss) private var dismiss
    private let model: RecentsSceneViewModel

    public init(model: RecentsSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(model.models) { assetModel in
                    NavigationCustomLink(
                        with: ListItemView(
                            title: assetModel.name,
                            imageStyle: .asset(assetImage: assetModel.assetImage)
                        )
                    ) {
                        model.onSelect(assetModel.asset)
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }
            .listStyle(.insetGrouped)
            .contentMargins(.top, .scene.top, for: .scrollContent)
            .navigationTitle(Localized.RecentActivity.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
