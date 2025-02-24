// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import NFT
import Primitives
import Components
import Localization

public struct CollectibleNavigationView: View {
    
    @State private var isPresentingSelectedAssetInput: SelectedAssetInput?
    @State private var isPresentingCollectibleOptions = false

    @Environment(\.avatarService) private var avatarService

    private let model: CollectibleNavigationViewModel
    
    init(
        model: CollectibleNavigationViewModel
    ) {
        self.model = model
    }
    
    public var body: some View {
        NFTDetailsScene(
            model: NFTDetailsViewModel(
                wallet: model.wallet,
                assetData: model.assetData,
                avatarService: avatarService,
                headerButtonAction: onHeaderButtonAction(type:)
            ),
            isPresentingCollectibleOptions: $isPresentingCollectibleOptions
        )
        .sheet(item: $isPresentingSelectedAssetInput) {
            SelectedAssetNavigationStack(
                selectType: $0,
                wallet: model.wallet,
                isPresentingSelectedAssetInput: $isPresentingSelectedAssetInput
            )
        }
    }
    
    private func onHeaderButtonAction(type: HeaderButtonType) {
        guard let account = try? model.wallet.account(for: model.assetData.asset.chain) else {
            return
        }
        switch type {
        case .send:
            isPresentingSelectedAssetInput = SelectedAssetInput(
                type: .send(.nft(model.assetData.asset)),
                assetAddress: AssetAddress(asset: account.chain.asset, address: account.address)
            )
        case .buy, .receive, .swap, .stake:
            fatalError()
        case .more:
            isPresentingCollectibleOptions = true
        }
    }
}
