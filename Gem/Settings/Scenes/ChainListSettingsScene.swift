// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style
import Localization

struct ChainListSettingsScene: View {

    let model = ChainListSettingsViewModel()

    var body: some View {
        SearchableListView(
            items: model.chains,
            filter: model.filter(_:query:),
            content: { chain in
                NavigationLink(value: Scenes.ChainSettings(chain: chain)) {
                    SimpleListItemView(model: ChainViewModel(chain: chain))
                }
            },
            emptyContent: {
                StateEmptyView(
                    title: Localized.Common.noResultsFound,
                    image: Images.System.searchNoResults
                )
            }
        )
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
