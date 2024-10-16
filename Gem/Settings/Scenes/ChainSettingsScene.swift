// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Settings
import Components
import GemstonePrimitives
import Style
import Localization

struct ChainSettingsScene: View {
    @Environment(\.nodeService) private var nodeService

    @State private var model: ChainSettingsViewModel

    init(model: ChainSettingsViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        List {
            Section(model.nodesTitle) {
                ForEach(model.nodesModels) { nodeModel in
                    ListItemSelectionView(
                        title: nodeModel.title,
                        titleExtra: nodeModel.titleExtra,
                        subtitle: nodeModel.subtitle,
                        subtitleExtra: .none,
                        placeholders: nodeModel.placeholders,
                        selectionDirection: .left,
                        value: nodeModel.chainNode.host,
                        selection: model.selectedNode.host
                    ) { _ in
                        onSelectNode(nodeModel.chainNode)
                    }
                    .contextMenu {
                        ContextMenuCopy(title: Localized.Common.copy, value: nodeModel.chainNode.node.url)
                    }
                    .if(model.canDelete(node: nodeModel.chainNode)) {
                        $0.swipeActions(edge: .trailing) {
                            Button(Localized.Common.delete) {
                                onSelectDelete(nodeModel.chainNode)
                            }
                            .tint(Colors.red)
                        }
                    }
                }
            }
            Section(model.explorerTitle) {
                ForEach(model.explorers) { explorer in
                    ListItemSelectionView(
                        title: explorer,
                        titleExtra: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
                        value: explorer,
                        selection: model.selectedExplorer,
                        action: onSelectExplorer(name:)
                    )
                }
            }
        }
        .refreshable {
            await fetch()
        }
        .confirmationDialog(
            Localized.Common.deleteConfirmation(model.nodeDelete?.host ?? ""),
            presenting: $model.nodeDelete,
            sensoryFeedback: .warning,
            actions: { chainNode in
                Button(
                    Localized.Common.delete,
                    role: .destructive,
                    action: onDeleteNode
                )
            }
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onSelectImportNode) {
                    Image(systemName: SystemImage.plus)
                        .font(.body.weight(.semibold))
                }
            }
        }
        .sheet(isPresented: $model.isPresentingImportNode) {
            NavigationStack {
                AddNodeScene(
                    model: AddNodeSceneViewModel(chain: model.chain, nodeService: nodeService),
                    onDismiss: onDismissAddCustomNode
                )
            }
        }
        .navigationTitle(model.title)
        .taskOnce {
            Task { await fetch()}
        }
    }
}

// MARK: - Actions

extension ChainSettingsScene {
    private func onSelectNode(_ node: ChainNode) {
        do {
            try model.select(node: node)
        } catch {
            // TODO: - handle error
            print("chain settings scene: on chain select error \(error)")
        }
    }

    private func onSelectDelete(_ chainNode: ChainNode) {
        model.nodeDelete = chainNode
    }

    private func onSelectExplorer(name: String) {
        model.selectExplorer(name: name)
    }

    private func onSelectImportNode() {
        model.isPresentingImportNode = true
    }

    private func onDismissAddCustomNode() {
        model.isPresentingImportNode = false
        Task {
            await fetch()
        }
    }

    private func onDeleteNode() {
        do {
            try model.delete()
        } catch {
            // TODO: - handle error
            print("chain settings scene: on delete error \(error)")
        }
    }
}

// MARK: - Effects

extension ChainSettingsScene {
    private func fetch() async {
        do {
            model.clear()
            try model.fetchNodes()
            await model.fetchNodesStatusInfo()
        } catch {
            // TODO: - handle error
            print("chain settings scene: fetch error \(error)")
        }
    }
}
