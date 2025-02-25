// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import SwapService
import ChainService
import class Swap.SwapPairSelectorViewModel
import Components
import Localization

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
            model.pairSelectorModel?.fromAssetId = asset.id
        case .receive:
            model.pairSelectorModel?.toAssetId = asset.id
        }
        isPresentingAssetSwapType = .none
    }
    
    private func onSelectProvider(_ list: [SwapProviderItem]) {
        model.selectedProvider = list.first?.swapQuote.data.provider
        navigationPath.wrappedValue.removeLast()
    }
}
