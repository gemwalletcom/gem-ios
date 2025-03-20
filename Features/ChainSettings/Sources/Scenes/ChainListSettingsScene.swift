// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents

public struct ChainListSettingsScene: View {
    private let model: ChainListSettingsViewModel

    public init(model: ChainListSettingsViewModel = ChainListSettingsViewModel()) {
        self.model = model
    }

    public var body: some View {
        SearchableListView(
            items: model.chains,
            filter: model.filter(_:query:),
            content: { chain in
                NavigationLink(value: Scenes.ChainSettings(chain: chain)) {
                    ChainView(model: ChainViewModel(chain: chain))
                }
            },
            emptyContent: {
                EmptyContentView(model: model.emptyContent)
            }
        )
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
