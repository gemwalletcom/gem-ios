// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization

struct SelectedAssetNavigationStack: View  {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService

    @State private var navigationPath = NavigationPath()
    @Binding private var isPresentingAssetSelectType: SelectAssetInput?

    private let selectType: SelectAssetInput
    private let wallet: Wallet
        
    init(
        selectType: SelectAssetInput,
        wallet: Wallet,
        isPresentingAssetSelectType: Binding<SelectAssetInput?>
    ) {
        self.selectType = selectType
        self.wallet = wallet
        _isPresentingAssetSelectType = isPresentingAssetSelectType
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            switch selectType.type {
            case .send:
                RecipientNavigationView(
                    wallet: wallet,
                    asset: selectType.asset,
                    navigationPath: $navigationPath
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingAssetSelectType = nil
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
                            isPresentingAssetSelectType = nil
                        }.bold()
                    }
                }
            case .buy:
                BuyAssetScene(
                    model: BuyAssetViewModel(
                        assetAddress: selectType.assetAddress,
                        input: .default
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingAssetSelectType = nil
                        }.bold()
                    }
                }
            case .swap:
                SwapScene(
                    model: SwapViewModel(
                        wallet: wallet,
                        assetId: selectType.asset.id,
                        walletsService: walletsService,
                        swapService: SwapService(nodeProvider: nodeService),
                        keystore: keystore
                    )
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingAssetSelectType = nil
                        }.bold()
                    }
                }
            case .stake:
                StakeNavigationView(
                    wallet: wallet,
                    assetId: selectType.asset.id,
                    navigationPath: $navigationPath
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            isPresentingAssetSelectType = nil
                        }.bold()
                    }
                }
            case .manage, .priceAlert:
                EmptyView()
            }
        }
    }
}


