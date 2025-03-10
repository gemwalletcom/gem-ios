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
    @State private var isPresentingSwapProviderSelect: Asset?

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
            isPresentingSwapProviderSelect: $isPresentingSwapProviderSelect,
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
        .sheet(item: $isPresentingAssetSwapType) { selectType in
            SelectAssetSceneNavigationStack(
                model: SelectAssetViewModel(
                    wallet: model.wallet,
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
        .sheet(item: $isPresentingSwapProviderSelect) { asset in
            SelectableListNavigationStack(
                model: model.swapProvidersViewModel(asset: asset),
                onFinishSelection: onSelectProvider,
                listContent: { SimpleListItemView(model: $0) }
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
        isPresentingSwapProviderSelect = nil
    }
}
