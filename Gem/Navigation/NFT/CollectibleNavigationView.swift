// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import NFT
import Primitives
import Components
import Localization

struct CollectibleNavigationView: View {
    
    @State private var isPresentingSelectedAssetInput: SelectedAssetInput?
    @Environment(\.avatarService) private var avatarService

    private let model: CollectibleNavigationViewModel
    
    init(
        model: CollectibleNavigationViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        CollectibleScene(
            model: CollectibleViewModel(
                wallet: model.wallet,
                assetData: model.assetData,
                avatarService: avatarService,
                headerButtonAction: onHeaderButtonAction(type:)
            )
        )
        .sheet(item: $isPresentingSelectedAssetInput) {
            SelectedAssetNavigationStack(
                selectType: $0,
                wallet: model.wallet,
                onComplete: onComplete
            )
        }
    }
}

// MARK: - Actions

extension CollectibleNavigationView {
    private func onComplete() {
        isPresentingSelectedAssetInput = nil
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
        case .buy, .receive, .swap, .stake, .more:
            fatalError()
        }
    }
}
