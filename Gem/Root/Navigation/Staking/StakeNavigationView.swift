// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Transfer
import Staking
import ChainService
import NodeService

struct StakeNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.walletsService) private var walletsService

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
                    keystore: keystore,
                    data: $0,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: $0.recipientData.asset.chain),
                    walletsService: walletsService,
                    onComplete: { _ in
                        self.onComplete?()
                    }
                )
            )
        }
        .navigationDestination(for: AmountInput.self) {
            AmountScene(
                model: AmounViewModel(
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
                    }
                )
            )
        }
    }
}
