// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import SwapService
import ChainService
import class Swap.SwapPairSelectorViewModel

struct SwapNavigationStack: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.navigationState) private var navigationState
    
    @State private var isPresentingAssetSwapType: SelectAssetSwapType?

    @State private var model: SwapViewModel

    private let onComplete: VoidAction

    private var navigationPath: Binding<NavigationPath>
    
    init(
        model: SwapViewModel,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        self.model = model
        self.onComplete = onComplete
        self.navigationPath = navigationPath
    }
    
    var body: some View {
        NavigationStack(path: navigationPath) {
            SwapScene(
                model: model,
                isPresentingAssetSwapType: $isPresentingAssetSwapType,
                onTransferAction: {
                    navigationPath.wrappedValue.append($0)
                }
            )
            .navigationDestination(for: TransferData.self) { data in
                ConfirmTransferScene(
                    model: ConfirmTransferViewModel(
                        wallet: model.wallet,
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
            .navigationDestination(for: Scenes.SwapProviders.self) {
                SwapProvidersScene(
                    model: model.swapProvidersViewModel(
                        asset: $0.asset,
                        swapQuotes: $0.swapQuotes
                    )
                )
            }
            .sheet(item: $isPresentingAssetSwapType) { selectType in
                SelectAssetSceneNavigationStack(
                    model: SelectAssetViewModel(
                        wallet: model.wallet,
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
    }
    
    static func defaultSwapPair(for asset: Asset?) -> SwapPairSelectorViewModel {
        if asset?.type == .native {
            return SwapPairSelectorViewModel(
                fromAssetId: asset?.chain.assetId,
                toAssetId: Chain.allCases
                    .sorted( by: { AssetScore.defaultRank(chain: $0) > AssetScore.defaultRank(chain: $1) })
                    .dropFirst().first?.assetId
            )
        }
        return SwapPairSelectorViewModel(
            fromAssetId: asset?.id,
            toAssetId: asset?.chain.assetId
        )
    }
}

// MARK: - Actions

extension SwapNavigationStack {
    private func onSwapComplete(type: TransferDataType) {
        switch type {
        case .swap, .tokenApprove:
            model.reset()
            onComplete?()
            navigationPath.wrappedValue.removeAll()
        default: break
        }
    }
    
    private func onSelectAssetComplete(type: SelectAssetSwapType, asset: Asset) {
        switch type {
        case .pay:
            model.pairSelectorModel.fromAssetId = asset.id
        case .receive:
            model.pairSelectorModel.toAssetId = asset.id
        }
        isPresentingAssetSwapType = .none
    }
}
