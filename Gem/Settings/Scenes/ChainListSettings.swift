// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct ChainListSettingsScene: View {

    @Environment(\.nodeService) private var nodeService

    let model = ChainListSettingsViewModel()
    @State private var searchQuery = ""

    var body: some View {
        List {
            ForEach(model.items(for: searchQuery)) { chain in
                NavigationLink(value: chain) {
                    ChainView(chain: chain)
                }
            }
        }
        .overlay {
            if model.items(for: searchQuery).isEmpty {
                StateEmptyView(title: Localized.Common.noResultsFound,
                               image: Image(systemName: SystemImage.searchNoResults))
            }
        }
        .navigationDestination(for: Chain.self) { chain in
            ChainSettingsScene(
                model: ChainSettingsViewModel(chain: chain, nodeService: nodeService)
            )
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .autocorrectionDisabled(true)
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: -

struct ChainView: View {
    
    let chain: Chain
    
    var body: some View {
        ListItemView(
            title: Asset(chain).name,
            image: Image(chain.id),
            imageSize: Sizing.image.chain,
            cornerRadius: Sizing.image.chain/2
        )
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        ChainListSettingsScene()
    }
}
