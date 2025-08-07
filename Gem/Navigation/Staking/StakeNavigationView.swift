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

struct StakeNavigationView: View {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @Environment(\.stakeService) private var stakeService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService

    private let wallet: Wallet
    private let assetId: AssetId

    @Binding private var navigationPath: NavigationPath

    private let onComplete: VoidAction

    init(
        wallet: Wallet,
        assetId: AssetId,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.assetId = assetId
        _navigationPath = navigationPath
        self.onComplete = onComplete
    }

    var body: some View {
        StakeScene(
            model: StakeViewModel(
                wallet: wallet,
                chain: assetId.chain,
                stakeService: stakeService,
                onTransferAction: {
                    navigationPath.append($0)
                },
                onAmountInputAction: {
                    navigationPath.append($0)
                }
            )
        )
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: viewModelFactory.confirmTransferScene(
                    wallet: wallet,
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
                    wallet: wallet,
                    onTransferAction: {
                        navigationPath.append($0)
                    }
                )
            )
        }
        .navigationDestination(for: Delegation.self) { delegation in
            StakeDetailScene(
                model: viewModelFactory.stakeDetailScene(
                    wallet: wallet,
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
