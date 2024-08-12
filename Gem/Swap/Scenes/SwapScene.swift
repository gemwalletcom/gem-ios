// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import GRDBQuery
import Components
import Style
import BigInt
import Keystore

struct SwapScene: View {
    @Environment(\.nodeService) private var nodeService

    @Query<AssetRequest> var fromAsset: AssetData
    @Query<AssetRequest> var toAsset: AssetData
    @Query<TransactionsRequest> var tokenApprovals: [TransactionExtended]

    @State var model: SwapViewModel

    enum Field: Int, Hashable {
        case from, to
    }
    @FocusState private var focusedField: Field?

    init(model: SwapViewModel) {
        _model = State(initialValue: model)
        _fromAsset = Query(model.fromAssetRequest, in: \.db.dbQueue)
        _toAsset = Query(model.toAssetRequest, in: \.db.dbQueue)
        _tokenApprovals = Query(model.tokenApprovalsRequest, in: \.db.dbQueue)
    }

    var body: some View {
        VStack {
            swapList
            Spacer()
            VStack {
                StatefullButton(text: model.actionButtonTitle(fromAsset: fromAsset.asset, isApprovalProcessInProgress: !tokenApprovals.isEmpty),
                    viewState: model.swapAvailabilityState,
                    image: model.actionButtonImage(isApprovalProcessInProgress: !tokenApprovals.isEmpty),
                    infoTitle: model.actionButtonInfoTitle(fromAsset: fromAsset.asset, isApprovalProcessInProgress: !tokenApprovals.isEmpty),
                    action: onSelectActionButton
                )
                .disabled(model.shouldDisableActionButton(fromAssetData: fromAsset, isApprovalProcessInProgress: !tokenApprovals.isEmpty))
            }
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .navigationTitle(model.title)
        .background(Colors.grayBackground)
        .navigationDestination(for: $model.transferData) {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: model.keystore,
                    data: $0,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: $0.recipientData.asset.chain),
                    walletService: model.walletService
                )
            )
        }
        .debounce(value: $model.fromValue,
                  interval: SwapViewModel.quoteTaskDebounceTimeout,
                  action: onChangeFromValue)
        .onChange(of: fromAsset, onChangeAssetsSwapDirection)
        .onChange(of: tokenApprovals, onChangeTokenApprovals)
        .task {
            updateAssets()
        }
        .onAppear {
            if model.toValue.isEmpty {
                focusedField = .from
            }
        }
    }
}

// MARK: - UI Components

extension SwapScene {
    private var swapList: some View {
        List {
            Section {
                SwapTokenView(
                    model: model.swapTokenModel(from: fromAsset),
                    text: $model.fromValue,
                    balanceAction: onSelectFromBalance
                )
                .buttonStyle(.borderless)
                .focused($focusedField, equals: .from)
            } header: {
                Text(model.swapFromTitle)
            } footer: {
                SwapChangeView(fromId: $fromAsset.assetId, toId: $toAsset.assetId)
                    .offset(y: Spacing.medium)
                    .frame(maxWidth: .infinity)
                    .disabled(model.swapAvailabilityState.isLoading)
            }

            Section(model.swapToTitle) {
                SwapTokenView(
                    model: model.swapTokenModel(from: toAsset),
                    text: $model.toValue,
                    showLoading: model.swapAvailabilityState.isLoading,
                    disabledTextField: true,
                    balanceAction: {}
                )
                .focused($focusedField, equals: .to)
            }

            Section {
                TransactionsList(tokenApprovals, showSections: false)
            }

            if case let .error(error) = model.swapAvailabilityState {
                ListItemErrorView(errorTitle: model.errorTitle, error: error)
            }
        }
    }
}

// MARK: - Actions

extension SwapScene {
    @MainActor
    private func onSelectFromBalance() {
        model.setMaxFromValue(asset: fromAsset.asset, value: fromAsset.balance.available)
        focusedField = .none
    }

    @MainActor
    private func onSelectActionButton() {
        if model.swapAvailabilityState.isError {
            fetch()
        } else {
            swap()
        }
    }

    @MainActor
    private func onChangeTokenApprovals() {
        if tokenApprovals.isEmpty {
            focusedField = .from
        }
        fetch()
    }

    @MainActor
    private func onChangeFromValue(_ value: String) async {
        model.toValue = ""
        await model.fetch(fromAssetData: fromAsset, toAsset: toAsset.asset)
    }

    @MainActor
    private func onChangeAssetsSwapDirection() {
        model.resetValues()
        focusedField = .from
        fetch()
    }
}

// MARK: - Effects

extension SwapScene {
    private func fetch() {
        Task {
            await model.fetch(fromAssetData: fromAsset, toAsset: toAsset.asset)
        }
    }

    func swap() {
        Task {
            await model.swap(fromAsset: fromAsset.asset, toAsset: toAsset.asset)
        }
    }

    func updateAssets() {
        Task {
            do {
                try await model.updateAssets(assetIds: [fromAsset.asset.id, toAsset.asset.id])
            } catch {
                // TODO: - handle error
                print("SwapScene updateAssets error: \(error)")
            }
        }
    }
}
