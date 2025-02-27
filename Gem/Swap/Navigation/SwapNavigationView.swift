// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import SwapService
import ChainService
import class Swap.SwapPairSelectorViewModel
import Components
import Localization

struct SwapNavigationView: View {
    @Environment(\.keystore) private var keystore
    @Environment(\.walletsService) private var walletsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    
    @State private var model: SwapViewModel
    @State private var isPresentingAssetSwapType: SelectAssetSwapType?

    private let onComplete: VoidAction
    @Binding private var navigationPath: NavigationPath
    
    init(
        model: SwapViewModel,
        navigationPath: Binding<NavigationPath>,
        onComplete: VoidAction
    ) {
        self.model = model
        self.onComplete = onComplete
        _navigationPath = navigationPath
    }
    
    var body: some View {
        SwapScene(
            model: model,
            isPresentingAssetSwapType: $isPresentingAssetSwapType,
            onTransferAction: {
                navigationPath.append($0)
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
            SelectableListView(
                model: .constant(model.swapProvidersViewModel(asset: $0.asset)),
                onFinishSelection: onSelectProvider,
                listContent: { SimpleListItemView(model: $0) }
            )
            .navigationTitle(Localized.Buy.Providers.title)
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
            if asset.id == model.pairSelectorModel.toAssetId {
                model.pairSelectorModel.toAssetId = model.pairSelectorModel.fromAssetId
            }
            model.pairSelectorModel.fromAssetId = asset.id
        case .receive:
            if asset.id == model.pairSelectorModel.fromAssetId {
                model.pairSelectorModel.fromAssetId = model.pairSelectorModel.toAssetId
            }
            model.pairSelectorModel.toAssetId = asset.id
        }
        isPresentingAssetSwapType = .none
    }
    
    private func onSelectProvider(_ list: [SwapProviderItem]) {
        model.setSelectedSwapQuote(list.first?.swapQuote)
        navigationPath.removeLast()
    }
}
