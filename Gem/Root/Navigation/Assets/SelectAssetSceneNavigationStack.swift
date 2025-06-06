// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization
import FiatConnect
import PrimitivesComponents
import Keystore
import Assets

struct SelectAssetSceneNavigationStack: View {
    @Environment(\.assetsService) private var assetsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.keystore) private var keystore
    @Environment(\.stakeService) private var stakeService

    @State private var isPresentingAddToken: Bool = false
    @State private var isPresentingFilteringView: Bool = false

    @State private var model: SelectAssetViewModel
    @State private var navigationPath = NavigationPath()
    @Binding private var isPresentingSelectAssetType: SelectAssetType?
    
    init(
        model: SelectAssetViewModel,
        isPresentingSelectType: Binding<SelectAssetType?>
    ) {
        _model = State(wrappedValue: model)
        _isPresentingSelectAssetType = isPresentingSelectType
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SelectAssetScene(
                model: model,
                isPresentingAddToken: $isPresentingAddToken
            )
            .toolbar {
                ToolbarDismissItem(
                    title: .done,
                    placement: .topBarLeading
                )
                if model.showFilter {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        FilterButton(
                            isActive: model.filterModel.isAnyFilterSpecified,
                            action: onSelectFilter
                        )
                    }
                }
                if model.showAddToken {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresentingAddToken = true
                        } label: {
                            Images.System.plus
                        }
                        .accessibilityIdentifier(.plusButton)
                    }
                }
            }
            .navigationDestination(for: SelectAssetInput.self) { input in
                switch input.type {
                case .send:
                    RecipientNavigationView(
                        model: RecipientSceneViewModel(
                            wallet: model.wallet,
                            asset: input.asset,
                            keystore: keystore,
                            walletService: walletService,
                            walletsService: walletsService,
                            nodeService: nodeService,
                            stakeService: stakeService,
                            type: .asset(input.asset),
                            onRecipientDataAction: {
                                navigationPath.append($0)
                            },
                            onTransferAction: {
                                navigationPath.append($0)
                            }
                        ),
                        onComplete: {
                            isPresentingSelectAssetType = nil
                        }
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
                    FiatConnectNavigationView(
                        model: FiatSceneViewModel(
                            assetAddress: input.assetAddress,
                            walletId: model.wallet.id
                        )
                    )
                case .manage, .priceAlert, .swap:
                    EmptyView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingAddToken) {
            AddTokenNavigationStack(
                wallet: model.wallet,
                isPresenting: $isPresentingAddToken
            )
        }
        .sheet(isPresented: $isPresentingFilteringView) {
            NavigationStack {
                AssetsFilterScene(model: $model.filterModel)
            }
            .presentationDetentsForCurrentDeviceSize(expandable: true)
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Actions

extension SelectAssetSceneNavigationStack {
    private func onSelectFilter() {
        isPresentingFilteringView.toggle()
    }
}

