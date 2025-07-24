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
import Transfer
import SwapService
import ChainService

struct SelectAssetSceneNavigationStack: View {
    @Environment(\.assetsService) private var assetsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.keystore) private var keystore
    @Environment(\.stakeService) private var stakeService
    @Environment(\.scanService) private var scanService
    @Environment(\.swapService) private var swapService

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
                model: model
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
                            model.isPresentingAddToken = true
                        } label: {
                            Images.System.plus
                        }
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
                            scanService: scanService,
                            swapService: swapService,
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
                case .deposit:
                    AmountNavigationView(
                        model: AmountSceneViewModel(
                            input: AmountInput(
                                type: .deposit(
                                    recipient: RecipientData(
                                        recipient: Recipient(name: "Hyperliquid", address: "0x2Df1c51E09aECF9cacB7bc98cB1742757f163dF7", memo: .none),
                                        amount: .none
                                    )
                                ),
                                asset: input.asset
                            ),
                            wallet: model.wallet,
                            walletsService: walletsService,
                            stakeService: stakeService,
                            onTransferAction: {
                                navigationPath.append($0)
                            }
                        )
                    )
                case .manage, .priceAlert, .swap:
                    EmptyView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TransferData.self) { data in
                ConfirmTransferScene(
                    model: ConfirmTransferViewModel(
                        wallet: model.wallet,
                        data: data,
                        keystore: keystore,
                        chainService: ChainServiceFactory(nodeProvider: nodeService)
                            .service(for: data.chain),
                        scanService: scanService,
                        swapService: swapService,
                        walletsService: walletsService,
                        swapDataProvider: SwapQuoteDataProvider(
                            keystore: keystore,
                            swapService: swapService
                        ),
                        onComplete: {
                            isPresentingSelectAssetType = nil
                        }
                    )
                )
            }
        }
        .sheet(isPresented: $model.isPresentingAddToken) {
            AddTokenNavigationStack(
                wallet: model.wallet,
                isPresenting: $model.isPresentingAddToken
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

