// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Staking
import Transfer
import Store
import InfoSheet

struct StakeNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @State private var model: StakeSceneViewModel
    @Binding var navigationPath: NavigationPath

    init(
        wallet: Wallet,
        chain: Chain,
        viewModelFactory: ViewModelFactory,
        navigationPath: Binding<NavigationPath>
    ) {
        _model = State(initialValue: viewModelFactory.stakeScene(wallet: wallet, chain: chain))
        _navigationPath = navigationPath
    }

    var body: some View {
        StakeScene(model: model)
            .observeQuery(request: $model.request, value: $model.delegations)
            .observeQuery(request: $model.assetRequest, value: $model.assetData)
            .observeQuery(request: $model.validatorsRequest, value: $model.validators)
            .ifLet(model.stakeInfoUrl, content: { view, url in
                view.toolbarInfoButton(url: url)
            })
            .sheet(item: $model.isPresentingInfoSheet) {
                InfoSheetScene(type: $0)
            }
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
            .navigationDestination(for: Delegation.self) { delegation in
                StakeDetailScene(
                    model: viewModelFactory.stakeDetailScene(
                        wallet: model.wallet,
                        delegation: delegation,
                        onAmountInputAction: {
                            navigationPath.append($0)
                        },
                        onTransferAction: {
                            navigationPath.append($0)
                        }
                    )
                )
            }
    }
}
