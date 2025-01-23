// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization

struct AssetNavigationView: View {

    let wallet: Wallet
    let assetId: AssetId

    @Binding private var isPresentingAssetSelectType: SelectAssetInput?
    @State private var transferData: TransferData?
    
    init(
        wallet: Wallet,
        assetId: AssetId,
        isPresentingAssetSelectType: Binding<SelectAssetInput?>
    ) {
        self.wallet = wallet
        self.assetId = assetId
        _isPresentingAssetSelectType = isPresentingAssetSelectType
    }

    var body: some View {
        AssetScene(
            wallet: wallet,
            input: AssetSceneInput(walletId: wallet.walletId, assetId: assetId),
            isPresentingAssetSelectType: $isPresentingAssetSelectType) { asset in
                transferData = TransferData(
                    type: .account(asset, .activate),
                    recipientData: RecipientData(
                        asset: asset,
                        recipient: Recipient(
                            name: .none,
                            address: "",
                            memo: .none
                        ),
                        amount: .none
                    ),
                    value: 0,
                    canChangeValue: false,
                    ignoreValueCheck: true
                )
            }
        .sheet(item: $transferData) { data in
            ConfirmTransferNavigationStack(
                wallet: wallet,
                transferData: data
            ) { _ in
                transferData = .none
            }
        }
    }
}
