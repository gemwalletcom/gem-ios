// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Yield
import Transfer

struct YieldNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    @State private var model: YieldSceneViewModel
    @Binding private var navigationPath: NavigationPath

    init(
        model: YieldSceneViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        _model = State(initialValue: model)
        _navigationPath = navigationPath
    }

    var body: some View {
        YieldScene(model: model)
            .navigationDestination(for: AmountInput.self) { input in
                AmountNavigationView(
                    model: viewModelFactory.amountScene(
                        input: input,
                        wallet: model.wallet,
                        onTransferAction: {
                            navigationPath.append($0)
                        }
                    )
                )
            }
    }
}
