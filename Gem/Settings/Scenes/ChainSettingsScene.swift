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
                ForEach(model.explorers) { explorer in
                    SelectionListItemView(title: explorer, subtitle: .none, value: explorer, selection: model.selectedExplorer) { _ in
                        onExplorerSelect(name: explorer)
                    }
                }
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

// MARK: - Actions

extension ChainSettingsScene {
    private func onExplorerSelect(name: String) {
        model.selectExplorer(name: name)
    }
}
