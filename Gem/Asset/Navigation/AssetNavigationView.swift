// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization

struct AssetNavigationView: View {

    let wallet: Wallet
    let assetId: AssetId

    @Binding private var isPresentingAssetSelectedInput: SelectedAssetInput?
    @State private var transferData: TransferData?
    
    init(
        wallet: Wallet,
        assetId: AssetId,
        isPresentingAssetSelectedInput: Binding<SelectedAssetInput?>
    ) {
        self.wallet = wallet
        self.assetId = assetId
        _isPresentingAssetSelectedInput = isPresentingAssetSelectedInput
    }

    var body: some View {
        AssetScene(
            wallet: wallet,
            input: AssetSceneInput(walletId: wallet.walletId, assetId: assetId),
            isPresentingAssetSelectedInput: $isPresentingAssetSelectedInput) { asset in
                transferData = TransferData(
                    type: .account(asset, .activate),
                    recipientData: RecipientData(
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
            ) {
                transferData = .none
            }
        }
    }
}
