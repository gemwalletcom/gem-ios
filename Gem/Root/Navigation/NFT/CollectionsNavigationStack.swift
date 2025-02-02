// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import NFT
import Components

public struct CollectionsNavigationStack: View {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.navigationState) private var navigationState
    @Environment(\.nftService) private var nftService
    @Environment(\.deviceService) private var deviceService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.openURL) private var openURL
    
    @State private var isPresentingReceiveSelectAssetType: SelectAssetType?
    @State private var isPresentingSelectedAssetInput: SelectedAssetInput?
    
    let model: NFTCollectionViewModel
    
    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.collections },
            set: { navigationState.collections = $0 }
        )
    }
    
    public var body: some View   {
        NavigationStack(path: navigationPath) {
            NFTScene(
                model: model,
                isPresentingSelectAssetType: $isPresentingReceiveSelectAssetType
            )
            .navigationDestination(for: Scenes.NFTCollectionScene.self) {
                NFTScene(
                    model: NFTCollectionViewModel(
                        wallet: model.wallet,
                        sceneStep: $0.sceneStep,
                        nftService: nftService,
                        deviceService: deviceService
                    ),
                    isPresentingSelectAssetType: $isPresentingReceiveSelectAssetType
                )
            }
            .navigationDestination(for: Scenes.NFTDetails.self) { assetData in
                NFTDetailsScene(
                    model: NFTDetailsViewModel(
                        assetData: assetData.assetData,
                        headerButtonAction: { type in
                            onHeaderButtonAction(type: type, assetData: assetData.assetData)
                        }
                    )
                )
            }
            .sheet(item: $isPresentingReceiveSelectAssetType) { value in
                SelectAssetSceneNavigationStack(
                    model: SelectAssetViewModel(
                        wallet: model.wallet,
                        keystore: keystore,
                        selectType: value,
                        assetsService: walletsService.assetsService,
                        walletsService: walletsService
                    ),
                    isPresentingSelectType: $isPresentingReceiveSelectAssetType
                )
            }
            .sheet(item: $isPresentingSelectedAssetInput) {
                SelectedAssetNavigationStack(
                    selectType: $0,
                    wallet: model.wallet,
                    isPresentingSelectedAssetInput: $isPresentingSelectedAssetInput
                )
            }
        }
        .onChange(of: keystore.currentWallet, onWalletChange)
    }
    
    private func onHeaderButtonAction(type: HeaderButtonType, assetData: NFTAssetData) {
        let account = try! model.wallet.account(for: assetData.asset.chain)
        switch type {
        case .send:
            isPresentingSelectedAssetInput = SelectedAssetInput(
                type: .send(.nft(assetData.asset)),
                assetAddress: AssetAddress(asset: account.chain.asset, address: account.address)
            )
        case .buy, .receive, .swap, .stake:
            fatalError()
        case .more:
            if let url = assetData.collection.links.first?.url, let url = URL(string: url) {
                openURL(url)
            }
        }
    }
}

extension CollectionsNavigationStack {
    private func onWalletChange(_ _: Wallet?, wallet: Wallet?) {
        Task {
            await model.fetch()
        }
    }
}
