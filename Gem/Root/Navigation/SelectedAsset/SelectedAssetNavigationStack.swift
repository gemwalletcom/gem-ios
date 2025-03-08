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
import Style

struct SelectedAssetNavigationStack: View  {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService

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
            switch selectType.type {
            case .send(let type):
                RecipientNavigationView(
                    model: RecipientViewModel(
                        wallet: wallet,
                        asset: selectType.asset,
                        keystore: keystore,
                        type: type,
                        onRecipientDataAction: {
                            navigationPath.append($0)
                        },
                        onTransferAction: {
                            navigationPath.append($0)
                        }
                    ),
                    navigationPath: $navigationPath,
                    onComplete: {
                        isPresentingSelectedAssetInput = nil
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingSelectedAssetInput = nil
                        }.bold()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            case .receive:
                ReceiveScene(
                    model: ReceiveViewModel(
                        assetModel: AssetViewModel(asset: selectType.asset),
                        walletId: wallet.walletId,
                        address: selectType.address,
                        walletsService: walletsService
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingSelectedAssetInput = nil
                        }.bold()
                    }
                }
            case .buy:
                FiatConnectNavigationView(
                    model: FiatSceneViewModel(
                        assetAddress: selectType.assetAddress,
                        walletId: wallet.id
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingSelectedAssetInput = nil
                        }.bold()
                    }
                }
            case .swap:
                SwapNavigationView(
                    model: SwapViewModel(
                        wallet: wallet,
                        pairSelectorModel: SwapPairSelectorViewModel.defaultSwapPair(for: selectType.asset),
                        walletsService: walletsService,
                        swapService: SwapService(nodeProvider: nodeService),
                        keystore: keystore
                    ),
                    navigationPath: $navigationPath,
                    onComplete: {
                        isPresentingSelectedAssetInput = nil
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingSelectedAssetInput = nil
                        }.bold()
                    }
                }
            case .stake:
                StakeNavigationView(
                    wallet: wallet,
                    assetId: selectType.asset.id,
                    navigationPath: $navigationPath,
                    onComplete: {
                        isPresentingSelectedAssetInput = nil
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingSelectedAssetInput = nil
                        }.bold()
                    }
                }
            }
        }
    }
}


