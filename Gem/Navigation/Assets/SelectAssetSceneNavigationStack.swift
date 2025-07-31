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
import ChainService
import ExplorerService
import Signer

struct SelectAssetSceneNavigationStack: View {
    @Environment(\.assetsService) private var assetsService
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletService) private var walletService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.keystore) private var keystore
    @Environment(\.stakeService) private var stakeService
    @Environment(\.scanService) private var scanService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService
    @Environment(\.transactionService) private var transactionService

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
                        amountService: AmountService(
                            priceService: priceService,
                            balanceService: balanceService,
                            stakeService: stakeService
                        ),
                        confirmService: ConfirmServiceFactory.create(
                            keystore: keystore,
                            nodeService: nodeService,
                            walletsService: walletsService,
                            scanService: scanService,
                            balanceService: balanceService,
                            priceService: priceService,
                            transactionService: transactionService,
                            chain: input.asset.chain
                        ),
                        model: RecipientSceneViewModel(
                            wallet: model.wallet,
                            asset: input.asset,
                            walletService: walletService,
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
                                        recipient: .hyperliquid,
                                        amount: .none
                                    )
                                ),
                                asset: input.asset
                            ),
                            wallet: model.wallet,
                            amountService: AmountService(
                                priceService: priceService,
                                balanceService: balanceService,
                                stakeService: stakeService
                            ),
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
                        confirmService: ConfirmServiceFactory.create(
                            keystore: keystore,
                            nodeService: nodeService,
                            walletsService: walletsService,
                            scanService: scanService,
                            balanceService: balanceService,
                            priceService: priceService,
                            transactionService: transactionService,
                            chain: data.chain
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

