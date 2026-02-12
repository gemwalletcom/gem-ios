// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Components
import Style
import PrimitivesComponents

public struct ChainSettingsScene: View {
    @State private var model: ChainSettingsSceneViewModel

    public init(model: ChainSettingsSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Section(model.nodesTitle) {
                ForEach(model.nodesModels) { nodeModel in
                    ListItemSelectionView(
                        title: nodeModel.title,
                        titleExtra: nodeModel.titleExtra,
                        titleTag: nodeModel.titleTag,
                        titleTagType: nodeModel.titleTagType,
                        titleTagStyle: nodeModel.titleTagStyle,
                        subtitle: .none,
                        subtitleExtra: .none,
                        value: nodeModel.chainNode.host,
                        selection: model.selectedNode.host
                    ) { _ in
                        model.onSelectNode(nodeModel.chainNode)
                    }
                    .contextMenu(
                        .copy(value: nodeModel.chainNode.node.url)
                    )
                    .if(model.canDelete(node: nodeModel.chainNode)) {
                        $0.swipeActions(edge: .trailing) {
                            Button(model.deleteButtonTitle, role: .destructive) {
                                model.onSelectNodeForDeletion(nodeModel.chainNode)
                            }
                            .tint(Colors.red)
                        }
                    }
                }
            }
            
            Section(model.explorerTitle) {
                ForEach(model.explorers, id: \.self) { explorer in
                    ListItemSelectionView(
                        title: explorer,
                        titleExtra: .none,
                        titleTag: .none,
                        titleTagType: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
                        value: explorer,
                        selection: model.selectedExplorer,
                        action: model.onSelectExplorer(name:)
                    )
                }
            }
        }
        .refreshable {
            await model.fetch()
        }
        .alert(
            model.deleteConfirmationTitle(for: model.nodeDelete?.host ?? ""),
            presenting: $model.nodeDelete,
            sensoryFeedback: .warning,
            actions: { chainNode in
                Button(
                    model.deleteButtonTitle,
                    role: .destructive,
                    action: model.onDeleteNode
                )
            }
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: model.onPresentImportNode) {
                    Images.System.plus
                        .font(.body.weight(.semibold))
                }
            }
        }
        .sheet(isPresented: $model.isPresentingImportNode) {
            NavigationStack {
                AddNodeScene(
                    model: AddNodeSceneViewModel(
                        chain: model.chain,
                        nodeService: model.nodeService,
                        chainServiceFactory: model.chainServiceFactory
                    ),
                    onDismiss: model.onDismissImportNode
                )
            }
        }
        .navigationTitle(model.title)
        .listSectionSpacing(.compact)
        .taskOnce {
            Task { await model.fetch()}
        }
    }
}
