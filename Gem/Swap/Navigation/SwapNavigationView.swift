// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import SwapService
import ChainService
import class Swap.SwapPairSelectorViewModel

struct SwapNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    
    @State private var isPresentingAssetSwapType: SelectAssetSwapType?
    
    @State private var pairSelectorModel: SwapPairSelectorViewModel
    
    private let wallet: Wallet
    private let onComplete: VoidAction

    @Binding private var navigationPath: NavigationPath
    
    init(
        wallet: Wallet,
        asset: Asset,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.pairSelectorModel = Self.defaultSwapPair(for: asset)
        
        _navigationPath = navigationPath
        self.onComplete = onComplete
    }
    
    var body: some View {
        SwapScene(
            model: SwapViewModel(
                wallet: wallet,
                pairSelectorModel: pairSelectorModel,
                walletsService: walletsService,
                swapService: SwapService(nodeProvider: nodeService),
                keystore: keystore,
                onSelectAsset: {
                    isPresentingAssetSwapType = $0
                },
                onTransferAction: {
                    self.navigationPath.append($0)
                },
                onComplete: onComplete
            )
        )
        .navigationDestination(for: TransferData.self) { data in
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: wallet,
                    keystore: keystore,
                    data: data,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: data.chain),
                    walletsService: walletsService,
                    onComplete: {
                        onSwapComplete(type: data.type)
                    }
                )
            )
        }
        .sheet(item: $isPresentingAssetSwapType) { selectType in
            SelectAssetSceneNavigationStack(
                model: SelectAssetViewModel(
                    wallet: wallet,
                    keystore: keystore,
                    selectType: .swap(selectType),
                    assetsService: assetsService,
                    walletsService: walletsService,
                    selectAssetAction: {
                        onSelectAssetComplete(type: selectType, asset: $0)
                    }
                ),
                isPresentingSelectType: .constant(.swap(selectType))
            )
        }
    }
    
    static func defaultSwapPair(for asset: Asset) -> SwapPairSelectorViewModel {
        if asset.type == .native {
            return SwapPairSelectorViewModel(
                fromAssetId: asset.chain.assetId,
                toAssetId: Chain.allCases
                    .sorted( by: { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) })
                    .dropFirst().first?.assetId
            )
        }
        return SwapPairSelectorViewModel(
            fromAssetId: asset.id,
            toAssetId: asset.chain.assetId
        )
    }
}

// MARK: - Actions

extension SwapNavigationView {
    private func onSwapComplete(type: TransferDataType) {
        switch type {
        case .swap, .tokenApprove:
            onComplete?()
        default: break
        }
    }
    
    private func onSelectAssetComplete(type: SelectAssetSwapType, asset: Asset) {
        switch type {
        case .pay:
            if asset.id == pairSelectorModel.toAssetId {
                pairSelectorModel.toAssetId = pairSelectorModel.fromAssetId
            }
            pairSelectorModel.fromAssetId = asset.id
        case .receive:
            if asset.id == pairSelectorModel.fromAssetId {
                pairSelectorModel.fromAssetId = pairSelectorModel.toAssetId
            }
            pairSelectorModel.toAssetId = asset.id
        }
        isPresentingAssetSwapType = .none
    }
}
