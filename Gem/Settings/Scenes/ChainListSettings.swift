// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style

struct ChainListSettingsScene: View {

    @Environment(\.nodeService) private var nodeService
    let model = ChainListSettingsViewModel()
    
    var body: some View {
        List {
            ForEach(model.chains) { chain in
                NavigationLink(value: chain) {
                    ChainView(chain: chain)
                }
            }
        }
        .navigationDestination(for: Chain.self) { chain in
            ChainSettingsScene(
                model: ChainSettingsViewModel(chain: chain, nodeService: nodeService)
            )
        }
        .navigationTitle(model.title)
    }
}

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
