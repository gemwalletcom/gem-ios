// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components

struct ManageContactNavigationStack: View {

    @State private var model: ManageContactViewModel
    @State private var path = NavigationPath()

    init(model: ManageContactViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ManageContactScene(model: $model)
                .toolbarDismissItem(type: .close, placement: .cancellationAction)
                .navigationDestination(for: Scenes.NetworksSelector.self) { _ in
                    ChainSelectorScene(
                        chain: model.chain,
                        onSelectChain: { chain in
                            model.onSelectChain(chain)
                            path.removeLast()
                        }
                    )
                }
        }
    }
}
