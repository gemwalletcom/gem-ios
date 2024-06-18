// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Settings
import Components
import GemstonePrimitives

struct ChainSettingsScene: View {
    @Environment(\.nodeService) private var nodeService
    @ObservedObject var model: ChainSettingsViewModel
    @State private var isPresentingImportNode: Bool = false

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
        .if(model.isSupportedAddingCustomNode) {
            $0.toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onSelectImportNode) {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                    }
                }
            }
            .sheet(isPresented: $isPresentingImportNode) {
                NavigationStack {
                    ImportNodeScene(
                        model: ImportNodeSceneViewModel(chain: model.chain, nodeService: nodeService),
                        onDismiss: onTaskOnce
                    )
                }
            }
        }
        .navigationTitle(model.title)
        .taskOnce {
            onTaskOnce()
        }
    }
}

// MARK: - Actions

extension ChainSettingsScene {
    private func onExplorerSelect(name: String) {
        model.selectExplorer(name: name)
    }

    private func onSelectImportNode() {
        isPresentingImportNode = true
    }

    private func onTaskOnce() {
        Task {
            try refreshNodes()
        }
    }
}

// MARK: - Effects

extension ChainSettingsScene {
    private func refreshNodes() throws {
        try model.nodes = model.getNodes()
    }
}
