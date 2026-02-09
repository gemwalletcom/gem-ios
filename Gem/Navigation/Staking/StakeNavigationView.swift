// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Transfer
import Staking
import InfoSheet

struct StakeNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    @State private var model: StakeSceneViewModel
    @Binding private var navigationPath: NavigationPath

    public init(
        model: StakeSceneViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        _model = State(initialValue: model)
        _navigationPath = navigationPath
    }

    var body: some View {
        StakeScene(
            model: model
        )
        .observeQuery(
            request: $model.request,
            value: $model.delegations
        )
        .observeQuery(
            request: $model.assetRequest,
            value: $model.assetData
        )
        .observeQuery(
            request: $model.validatorsRequest,
            value: $model.validators
        )
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
