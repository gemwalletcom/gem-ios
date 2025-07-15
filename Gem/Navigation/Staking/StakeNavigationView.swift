// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Transfer
import Staking
import ChainService
import NodeService
import SwapService

struct StakeNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.scanService) private var scanService
    @Environment(\.swapService) private var swapService

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
        .navigationDestination(for: TransferData.self) {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: wallet,
                    data: $0,
                    keystore: keystore,
                    chainService: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: $0.chain),
                    scanService: scanService,
                    swapService: swapService,
                    walletsService: walletsService,
                    swapDataProvider: SwapQuoteDataProvider(
                        keystore: keystore,
                        swapService: swapService
                    ),
                    onComplete: onComplete
                )
            )
        }
        .navigationDestination(for: AmountInput.self) {
            AmountNavigationView(
                model: AmountSceneViewModel(
                    input: $0,
                    wallet: wallet,
                    walletsService: walletsService,
                    stakeService: stakeService,
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
