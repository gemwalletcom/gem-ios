// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Earn
import Transfer

struct EarnProtocolsNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    @State private var model: EarnProtocolsSceneViewModel
    @Binding private var navigationPath: NavigationPath

    init(
        model: EarnProtocolsSceneViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        _model = State(initialValue: model)
        _navigationPath = navigationPath
    }

    var body: some View {
        EarnProtocolsScene(model: model)
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
