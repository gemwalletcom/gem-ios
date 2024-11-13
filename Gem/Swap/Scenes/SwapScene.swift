// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import GRDBQuery
import Components
import Style
import BigInt
import Keystore
import ChainService

struct SelectSwapAssetId: Hashable {
    let type: SelectAssetSwapType
    let assetId: AssetId
}

struct SwapScene: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.walletsService) private var walletsService
    
    @Query<AssetRequestOptional>
    var fromAsset: AssetData?

    @Query<AssetRequestOptional>
    var toAsset: AssetData?
    
    @Query<TransactionsRequest>
    var tokenApprovals: [TransactionExtended]

    @State var model: SwapViewModel

    enum Field: Int, Hashable {
        case from, to
    }
    
    @FocusState private var focusedField: Field?

    init(
        model: SwapViewModel
    ) {
        _model = State(initialValue: model)
        _fromAsset = Query(model.fromAssetRequest)
        _toAsset = Query(model.toAssetRequest)
        _tokenApprovals = Query(model.tokenApprovalsRequest)
    }

    var body: some View {
        VStack {
            swapList
            Spacer()
            VStack {
                if let fromAsset {
                    StateButton(
                        text: model.actionButtonTitle(fromAsset: fromAsset.asset, isApprovalProcessInProgress: !tokenApprovals.isEmpty),
                        viewState: model.swapAvailabilityState,
                        image: model.actionButtonImage(isApprovalProcessInProgress: !tokenApprovals.isEmpty),
                        infoTitle: model.actionButtonInfoTitle(fromAsset: fromAsset.asset, isApprovalProcessInProgress: !tokenApprovals.isEmpty),
                        disabledRule: model.shouldDisableActionButton(fromAssetData: fromAsset, isApprovalProcessInProgress: !tokenApprovals.isEmpty),
                        action: onSelectActionButton
                    )
                }
            }
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .navigationTitle(model.title)
        .background(Colors.grayBackground)
        .debounce(
            value: $model.fromValue,
            interval: SwapViewModel.quoteTaskDebounceTimeout,
            action: onChangeFromValue
        )
        .onChange(of: fromAsset, onChangeFromAsset)
        .onChange(of: toAsset, onChangeToAsset)
        .onChange(of: tokenApprovals, onChangeTokenApprovals)
        .task {
            updateAssets()
        }
        .onChange(of: model.pairSelectorModel.fromAssetId) { _, new in
            $fromAsset.assetId.wrappedValue = new?.identifier
        }
        .onChange(of: model.pairSelectorModel.toAssetId) { _, new in
            $toAsset.assetId.wrappedValue = new?.identifier
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
                if let fromAsset {
                    SwapTokenView(
                        model: model.swapTokenModel(from: fromAsset, type: .pay),
                        text: $model.fromValue,
                        onBalanceAction: onSelectFromBalance,
                        onSelectAssetAction: onSelectAssetAction
                    )
                    .buttonStyle(.borderless)
                    .focused($focusedField, equals: .from)
                } else {
                    SwapTokenEmptyView(
                        type: .pay,
                        onSelectAssetAction: onSelectAssetAction
                    )
                }
                
            } header: {
                Text(model.swapFromTitle)
            } footer: {
                SwapChangeView(fromId: $fromAsset.assetId, toId: $toAsset.assetId)
                    .offset(y: Spacing.medium)
                    .frame(maxWidth: .infinity)
                    .disabled(model.swapAvailabilityState.isLoading)
            }

            Section(model.swapToTitle) {
                if let toAsset {
                    SwapTokenView(
                        model: model.swapTokenModel(from: toAsset, type: .receive),
                        text: $model.toValue,
                        showLoading: model.swapAvailabilityState.isLoading,
                        disabledTextField: true,
                        onBalanceAction: {},
                        onSelectAssetAction: onSelectAssetAction
                    )
                    .buttonStyle(.borderless)
                    .focused($focusedField, equals: .to)
                } else {
                    SwapTokenEmptyView(
                        type: .receive,
                        onSelectAssetAction: onSelectAssetAction
                    )
                }
            }
            
            Section {
                if let priceImpactValue = model.priceImpactValue {
                    ListItemView(
                        title: model.priceImpact,
                        subtitle: priceImpactValue
                    )
                }
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
        guard let fromAsset, let _ = toAsset else { return }
        model.setMaxFromValue(asset: fromAsset.asset, value: fromAsset.balance.available)
        focusedField = .none
    }
    
    @MainActor
    private func onSelectAssetAction(type: SelectAssetSwapType) {
        model.onSelectAssetAction(type: type)
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
        guard let fromAsset, let toAsset else { return }
        await model.fetch(fromAssetData: fromAsset, toAsset: toAsset.asset)
    }

    @MainActor
    private func onChangeFromAsset() {
        model.resetValues()
        focusedField = .from
        fetch()
    }
    
    @MainActor
    private func onChangeToAsset() {
        model.resetToValue()
        fetch()
    }
}

// MARK: - Effects

extension SwapScene {
    private func fetch() {
        Task {
            guard let fromAsset, let toAsset else { return }
            await model.fetch(fromAssetData: fromAsset, toAsset: toAsset.asset)
        }
    }

    func swap() {
        Task {
            guard let fromAsset, let toAsset else { return }
            await model.swap(fromAsset: fromAsset.asset, toAsset: toAsset.asset)
        }
    }

    func updateAssets() {
        Task {
            let assetIds = [fromAsset?.asset.id, toAsset?.asset.id].compactMap { $0 }
            do {
                try await model.updateAssets(assetIds: assetIds)
            } catch {
                // TODO: - handle error
                print("SwapScene updateAssets error: \(error)")
            }
        }
    }
}
