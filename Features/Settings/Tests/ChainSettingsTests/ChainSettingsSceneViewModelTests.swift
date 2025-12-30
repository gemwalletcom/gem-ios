// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import NodeServiceTestKit
@testable import Settings

@MainActor
struct ChainSettingsSceneViewModelTests {

    @Test
    func selectedNodeReturnsDefaultWhenNotSet() {
        let viewModel = ChainSettingsSceneViewModel(nodeService: .mock(), chain: .ethereum)

        #expect(viewModel.selectedNode.node.url == Chain.ethereum.defaultChainNode.node.url)
    }

    @Test
    func onSelectNodeStoresNode() {
        let viewModel = ChainSettingsSceneViewModel(nodeService: .mock(), chain: .ethereum)

        viewModel.onSelectNode(Chain.ethereum.asiaChainNode)

        #expect(viewModel.selectedNode.node.url == Chain.ethereum.asiaChainNode.node.url)
    }

    @Test
    func switchNode() {
        let viewModel = ChainSettingsSceneViewModel(nodeService: .mock(), chain: .ethereum)

        viewModel.onSelectNode(Chain.ethereum.asiaChainNode)
        #expect(viewModel.selectedNode.node.url == Chain.ethereum.asiaChainNode.node.url)

        viewModel.onSelectNode(Chain.ethereum.europeChainNode)
        #expect(viewModel.selectedNode.node.url == Chain.ethereum.europeChainNode.node.url)
    }
}
