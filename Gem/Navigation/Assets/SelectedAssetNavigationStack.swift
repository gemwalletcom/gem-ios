// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization
import SwapService
import FiatConnect
import PrimitivesComponents
import PriceAlerts
import Swap
import Assets
import Transfer
import ChainService
import ExplorerService
import Signer
import EventPresenterService

struct SelectedAssetNavigationStack: View  {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @Environment(\.keystore) private var keystore
    @Environment(\.chainServiceFactory) private var chainServiceFactory
    @Environment(\.assetsEnabler) private var assetsEnabler
    @Environment(\.scanService) private var scanService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService
    @Environment(\.transactionStateService) private var transactionStateService
    @Environment(\.addressNameService) private var addressNameService
    @Environment(\.activityService) private var activityService
    @Environment(\.eventPresenterService) private var eventPresenterService

    @State private var navigationPath = NavigationPath()

    private let input: SelectedAssetInput
    private let wallet: Wallet
    private let onComplete: VoidAction

    init(
        input: SelectedAssetInput,
        wallet: Wallet,
        onComplete: VoidAction
    ) {
        self.input = input
        self.wallet = wallet
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch input.type {
                case .send(let type):
                    RecipientNavigationView(
                        confirmService: ConfirmServiceFactory.create(
                            keystore: keystore,
                            chainServiceFactory: chainServiceFactory,
                            assetsEnabler: assetsEnabler,
                            scanService: scanService,
                            balanceService: balanceService,
                            priceService: priceService,
                            transactionStateService: transactionStateService,
                            addressNameService: addressNameService,
                            activityService: activityService,
                            eventPresenterService: eventPresenterService,
                            chain: input.asset.chain
                        ),
                        model: viewModelFactory.recipientScene(
                            wallet: wallet,
                            asset: input.asset,
                            type: type,
                            onRecipientDataAction: {
                                navigationPath.append($0)
                            },
                            onTransferAction: {
                                navigationPath.append($0)
                            }
                        )
                    )
                case .receive:
                    ReceiveScene(
                        model: ReceiveViewModel(
                            assetModel: AssetViewModel(asset: input.asset),
                            wallet: wallet,
                            address: input.address,
                            assetsEnabler: assetsEnabler
                        )
                    )
                case let .buy(_, amount):
                    FiatConnectNavigationView(
                        model: viewModelFactory.fiatScene(
                            assetAddress: input.assetAddress,
                            walletId: wallet.walletId,
                            type: .buy,
                            amount: amount
                        )
                    )
                case let .sell(_, amount):
                    FiatConnectNavigationView(
                        model: viewModelFactory.fiatScene(
                            assetAddress: input.assetAddress,
                            walletId: wallet.walletId,
                            type: .sell,
                            amount: amount
                        )
                    )
                case let .swap(fromAsset, toAsset):
                    SwapNavigationView(
                        model: viewModelFactory.swapScene(
                            input: SwapInput(
                                wallet: wallet,
                                pairSelector: SwapPairSelectorViewModel(
                                    fromAssetId: fromAsset.id,
                                    toAssetId: toAsset?.id ?? SwapPairSelectorViewModel.defaultSwapPair(for: fromAsset).toAssetId
                                )
                            ),
                            onSwap: {
                                navigationPath.append($0)
                            }
                        )
                    )
                case .stake:
                    StakeNavigationView(
                        model: viewModelFactory.stakeScene(
                            wallet: wallet,
                            chain: input.asset.id.chain
                        ),
                        navigationPath: $navigationPath
                    )
                }
            }
            .toolbarDismissItem(type: .close, placement: .topBarLeading)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TransferData.self) { data in
                ConfirmTransferScene(
                    model: viewModelFactory.confirmTransferScene(
                        wallet: wallet,
                        data: data,
                        onComplete: onComplete
                    )
                )
            }
            .taskOnce {
                updateRecent()
            }
        }
    }
}

// MARK: - Private

extension SelectedAssetNavigationStack {
    private func updateRecent() {
        if let data = input.type.recentActivityData(assetId: input.asset.id) {
            try? activityService.updateRecent(data: data, walletId: wallet.walletId)
        }
    }
}
