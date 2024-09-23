// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct SelectAssetSceneNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService

    @State private var isPresentingAddToken: Bool = false
    @State private var isPresentingFilteringView: Bool = false

    @State private var model: SelectAssetViewModel
    @State private var navigationPath = NavigationPath()

    init(model: SelectAssetViewModel) {
        _model = State(wrappedValue: model)
    }

    var body: some View {
        NavigationStack {
            SelectAssetScene(
                model: model,
                isPresentingAddToken: $isPresentingAddToken,
                navigationPath: $navigationPath
            )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            dismiss()
                        }
                        .bold()
                        .accessibilityIdentifier("cancel")
                    }
                    if model.showAddToken {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isPresentingFilteringView = true
                            } label: {
                                if model.filterModel.isCusomFilteringSpecified {
                                    Image(systemName: SystemImage.filterFill)
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(Colors.whiteSolid, Colors.blue)
                                } else {
                                    Image(systemName: SystemImage.filter)
                                        .foregroundStyle(.primary)
                                }
                            }
                            .contentTransition(.symbolEffect(.replace))
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isPresentingAddToken = true
                            } label: {
                                Image(systemName: SystemImage.plus)
                            }
                        }
                    }
                }
                .navigationDestination(for: SelectAssetInput.self) { input in
                    switch input.type {
                    case .send:
                        AmountNavigationView(
                            input: AmountInput(type: .transfer, asset: input.asset),
                            wallet: model.wallet,
                            navigationPath: $navigationPath
                        )
                    case .receive:
                        ReceiveScene(
                            model: ReceiveViewModel(
                                assetModel: AssetViewModel(asset: input.asset),
                                walletId: model.wallet.walletId,
                                address: input.assetAddress.address,
                                walletsService: walletsService
                            )
                        )
                    case .buy:
                        BuyAssetScene(
                            model: BuyAssetViewModel(
                                assetAddress: input.assetAddress,
                                input: .default)
                            )
                    case .swap:
                        SwapScene(
                            model: SwapViewModel(
                                wallet: model.wallet,
                                assetId: input.asset.id,
                                walletsService: walletsService,
                                swapService: SwapService(nodeProvider: nodeService),
                                keystore: keystore
                            )
                        )
                    case .manage, .stake, .priceAlert:
                        EmptyView()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingAddToken) {
            AddTokenNavigationStack(
                wallet: model.wallet,
                isPresenting: $isPresentingAddToken,
                action: addAsset
            )
        }
        .sheet(isPresented: $isPresentingFilteringView) {
            NavigationStack {
                AssetsFilterScene(model: $model.filterModel)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    func addAsset(_ asset: Asset) {
        Task {
            try model.assetsService.addAsset(walletId: model.wallet.walletId, asset: asset)
        }
        dismiss()
    }
}
