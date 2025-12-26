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
import EventPresenterService

struct SelectAssetSceneNavigationStack: View {
    @Environment(\.viewModelFactory) private var viewModelFactory
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.keystore) private var keystore
    @Environment(\.scanService) private var scanService
    @Environment(\.balanceService) private var balanceService
    @Environment(\.priceService) private var priceService
    @Environment(\.transactionStateService) private var transactionStateService
    @Environment(\.addressNameService) private var addressNameService
    @Environment(\.activityService) private var activityService
    @Environment(\.eventPresenterService) private var eventPresenterService

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
                Group {
                    switch input.type {
                    case .send:
                        RecipientNavigationView(
                            confirmService: ConfirmServiceFactory.create(
                                keystore: keystore,
                                nodeService: nodeService,
                                walletsService: walletsService,
                                scanService: scanService,
                                balanceService: balanceService,
                                priceService: priceService,
                                transactionStateService: transactionStateService,
                                addressNameService: addressNameService,
                                activityService: activityService,
                                eventPresenterService: eventPresenterService,
                                chain: input.asset.chain
                            ),
                            model: viewModelFactory.recipientScene(
                                wallet: model.wallet,
                                asset: input.asset,
                                type: .asset(input.asset),
                                onRecipientDataAction: {
                                    navigationPath.append($0)
                                },
                                onTransferAction: {
                                    navigationPath.append($0)
                                }
                            )
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
                            model: viewModelFactory.fiatScene(
                                assetAddress: input.assetAddress,
                                walletId: model.wallet.walletId
                            )
                        )
                    case .deposit:
                        AmountNavigationView(
                            model: viewModelFactory.amountScene(
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
                                onTransferAction: {
                                    navigationPath.append($0)
                                }
                            )
                        )
                    case .withdraw:
                        let withdrawRecipient = Recipient(
                            name: model.wallet.name,
                            address: input.assetAddress.address,
                            memo: nil
                        )
                        AmountNavigationView(
                            model: viewModelFactory.amountScene(
                                input: AmountInput(
                                    type: .withdraw(
                                        recipient: RecipientData(
                                            recipient: withdrawRecipient,
                                            amount: .none
                                        )
                                    ),
                                    asset: input.asset
                                ),
                                wallet: model.wallet,
                                onTransferAction: {
                                    navigationPath.append($0)
                                }
                            )
                        )
                    case .manage, .priceAlert, .swap:
                        EmptyView()
                    }
                }
                .taskOnce {
                    model.updateRecent(assetId: input.asset.id)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TransferData.self) { data in
                ConfirmTransferScene(
                    model: viewModelFactory.confirmTransferScene(
                        wallet: model.wallet,
                        data: data,
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
            .presentationBackground(Colors.grayBackground)
        }
    }
}

// MARK: - Actions

extension SelectAssetSceneNavigationStack {
    private func onSelectFilter() {
        isPresentingFilteringView.toggle()
    }
}
