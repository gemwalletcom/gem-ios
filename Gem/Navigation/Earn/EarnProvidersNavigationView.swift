// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Earn
import Transfer

struct EarnProvidersNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    @State private var model: EarnProvidersSceneViewModel
    @Binding private var navigationPath: NavigationPath

    init(
        model: EarnProvidersSceneViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        _model = State(initialValue: model)
        _navigationPath = navigationPath
    }

    var body: some View {
        EarnProvidersScene(model: model)
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
