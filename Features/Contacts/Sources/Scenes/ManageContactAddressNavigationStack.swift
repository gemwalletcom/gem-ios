// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components

struct ManageContactAddressNavigationStack: View {

    @State private var model: ManageContactAddressViewModel
    @State private var path = NavigationPath()

    init(model: ManageContactAddressViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ManageContactAddressScene(model: $model)
                .toolbarDismissItem(type: .close, placement: .cancellationAction)
                .navigationDestination(for: Scenes.NetworksSelector.self) { _ in
                    ChainSelectorScene(
                        chain: model.chain,
                        onSelectChain: {
                            model.onSelectChain($0)
                            path.removeLast()
                        }
                    )
                }
        }
    }
}
