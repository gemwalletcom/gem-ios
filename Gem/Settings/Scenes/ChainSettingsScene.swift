// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Settings
import Components
import GemstonePrimitives

struct ChainSettingsScene: View {
    
    @ObservedObject var model: ChainSettingsViewModel
    
    init(
        model: ChainSettingsViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        List {
            Section(Localized.Settings.Networks.source) {
                ForEach(model.nodes.map { ChainNodeViewModel(chainNode: $0) }, id: \.chainNode.id) { chainNode in
                    SelectionListItemView(
                        title: chainNode.title,
                        subtitle: .none,
                        value: chainNode.chainNode.host,
                        selection: model.chainNode.host
                    ) { _ in
                        model.chainNode = chainNode.chainNode
                    }
                }
            }
            Section(Localized.Settings.Networks.explorer) {
                ListItemView(title: ExplorerService.hostName(url: ExplorerService.transactionUrl(chain: model.chain, hash: "")))
            }
        }
        .navigationTitle(model.title)
        .taskOnce {
            Task {
                try model.nodes = model.getNodes()
            }
        }
    }
}
