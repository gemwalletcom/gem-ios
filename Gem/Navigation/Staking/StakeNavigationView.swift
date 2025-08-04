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
    @Environment(\.walletsService) private var walletsService
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
                model: viewModelFactory.confirmTransfer(
                    wallet: wallet,
                    data: data,
                    onComplete: onComplete
                )
            )
        }
        .navigationDestination(for: AmountInput.self) {
            AmountNavigationView(
                model: AmountSceneViewModel(
                    input: $0,
                    wallet: wallet,
                    amountService: AmountService(priceService: priceService, balanceService: balanceService, stakeService: stakeService),
                    onTransferAction: {
                        navigationPath.append($0)
                    }
                )
            )
        }
        .navigationDestination(for: Delegation.self) { value in
            StakeDetailScene(
                model: StakeDetailViewModel(
                    wallet: wallet,
                    model: StakeDelegationViewModel(delegation: value),
                    service: stakeService,
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
