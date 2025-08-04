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

struct SelectedAssetNavigationStack: View  {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.walletService) private var walletService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.scanService) private var scanService
    @Environment(\.swapService) private var swapService
    @Environment(\.nameService) private var nameService

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
                        ),
                        onComplete: onComplete
                    )
                case .receive:
                    ReceiveScene(
                        model: ReceiveViewModel(
                            assetModel: AssetViewModel(asset: input.asset),
                            walletId: wallet.walletId,
                            address: input.address,
                            walletsService: walletsService
                        )
                    )
                case .buy:
                    FiatConnectNavigationView(
                        model: FiatSceneViewModel(
                            assetAddress: input.assetAddress,
                            walletId: wallet.id
                        )
                    )
                case let .swap(fromAsset, toAsset):
                    SwapNavigationView(
                        model: SwapSceneViewModel(
                            input: SwapInput(
                                wallet: wallet,
                                pairSelector: SwapPairSelectorViewModel(
                                    fromAssetId: fromAsset.id,
                                    toAssetId: toAsset?.id ?? SwapPairSelectorViewModel.defaultSwapPair(for: fromAsset).toAssetId
                                )
                            ),
                            walletsService: walletsService,
                            swapQuotesProvider: SwapQuotesProvider(swapService: swapService),
                            swapQuoteDataProvider: SwapQuoteDataProvider(keystore: keystore, swapService: swapService),
                            onSwap: {
                                navigationPath.append($0)
                            }
                        ),
                        onComplete: onComplete
                    )
                case .stake:
                    StakeNavigationView(
                        wallet: wallet,
                        assetId: input.asset.id,
                        navigationPath: $navigationPath,
                        onComplete: onComplete
                    )
                }
            }
            .toolbarDismissItem(title: .done, placement: .topBarLeading)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
