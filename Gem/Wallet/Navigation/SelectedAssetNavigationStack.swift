// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization
import SwapService
import FiatConnect

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
                    navigationPath: $navigationPath,
                    onComplete: {
                        isPresentingAssetSelectType = nil
                    }
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
            case .buy, .sell:
                FiatConnectNavigationView(
                    assetAddress: selectType.assetAddress,
                    walletId: wallet.id,
                    type: selectType.fiatType,
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
            case .swap:
                SwapNavigationView(
                    wallet: wallet,
                    asset: selectType.asset,
                    navigationPath: $navigationPath,
                    onComplete: {
                        isPresentingAssetSelectType = nil
                    }
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
                    navigationPath: $navigationPath,
                    onComplete: {
                        isPresentingAssetSelectType = nil
                    }
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


