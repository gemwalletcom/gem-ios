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
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.walletService) private var walletService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.scanService) private var scanService

    @State private var navigationPath = NavigationPath()
    @Binding private var isPresentingSelectedAssetInput: SelectedAssetInput?

    private let selectType: SelectedAssetInput
    private let wallet: Wallet
        
    init(
        selectType: SelectedAssetInput,
        wallet: Wallet,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        self.selectType = selectType
        self.wallet = wallet
        _isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch selectType.type {
                case .send(let type):
                    RecipientNavigationView(
                        model: RecipientSceneViewModel(
                            wallet: wallet,
                            asset: selectType.asset,
                            keystore: keystore,
                            walletService: walletService,
                            walletsService: walletsService,
                            nodeService: nodeService,
                            stakeService: stakeService,
                            scanService: scanService,
                            swapService: SwapService(nodeProvider: nodeService),
                            type: type,
                            onRecipientDataAction: {
                                navigationPath.append($0)
                            },
                            onTransferAction: {
                                navigationPath.append($0)
                            }
                        ),
                        onComplete: {
                            isPresentingSelectedAssetInput = nil
                        }
                    )
                case .receive:
                    ReceiveScene(
                        model: ReceiveViewModel(
                            assetModel: AssetViewModel(asset: selectType.asset),
                            walletId: wallet.walletId,
                            address: selectType.address,
                            walletsService: walletsService
                        )
                    )
                case .buy:
                    FiatConnectNavigationView(
                        model: FiatSceneViewModel(
                            assetAddress: selectType.assetAddress,
                            walletId: wallet.id
                        )
                    )
                case .swap:
                    SwapNavigationView(
                        model: SwapSceneViewModel(
                            wallet: wallet,
                            asset: selectType.asset,
                            walletsService: walletsService,
                            swapQuotesProvider: SwapQuotesProvider(swapService: SwapService(nodeProvider: nodeService)),
                            onSwap: {
                                navigationPath.append($0)
                            }
                        ),
                        onComplete: {
                            isPresentingSelectedAssetInput = nil
                        }
                    )
                case .stake:
                    StakeNavigationView(
                        wallet: wallet,
                        assetId: selectType.asset.id,
                        navigationPath: $navigationPath,
                        onComplete: {
                            isPresentingSelectedAssetInput = nil
                        }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.done) {
                        isPresentingSelectedAssetInput = nil
                    }.bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
