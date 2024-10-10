// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct ChainListSettingsScene: View {

    let model = ChainListSettingsViewModel()

    var body: some View {
        SearchableListView(
            items: model.chains,
            filter: model.filter(_:query:),
            content: { chain in
                NavigationLink(value: Scenes.ChainSettings(chain: chain)) {
                    ChainView(chain: chain)
                }
            },
            emptyContent: {
                StateEmptyView(
                    title: Localized.Common.noResultsFound,
                    image: Image(systemName: SystemImage.searchNoResults)
                )
            }
        )
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
