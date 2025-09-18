// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Transfer
import Staking
import ChainService
import NodeService
import ExplorerService
import Signer
import InfoSheet

struct StakeNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @Environment(\.stakeService) private var stakeService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService

    @State private var model: StakeSceneViewModel
    @Binding private var navigationPath: NavigationPath

    private let onComplete: VoidAction

    public init(
        model: StakeSceneViewModel,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        _model = State(initialValue: model)
        _navigationPath = navigationPath
        self.onComplete = onComplete
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
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(type: $0)
        }
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: viewModelFactory.confirmTransferScene(
                    wallet: model.wallet,
                    data: data,
                    confirmTransferDelegate: nil,
                    onComplete: onComplete
                )
            )
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
