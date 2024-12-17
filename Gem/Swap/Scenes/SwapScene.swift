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
import struct Swap.SwapTokenEmptyView
import struct Swap.SwapChangeView

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
    
    // Update quote every 30 seconds, needed if you come back from the background.
    private let updateQuoteTimer = Timer.publish(every: 30, tolerance: 1, on: .main, in: .common).autoconnect()
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
                        viewState: model.actionButtonState,
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
            value: model.fromValue,
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
        .onReceive(updateQuoteTimer) { _ in
            fetch()
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
                        onSelectAssetAction: onSelectAssetPayAction
                    )
                    .buttonStyle(.borderless)
                    .focused($focusedField, equals: .from)
                } else {
                    SwapTokenEmptyView(
                        onSelectAssetAction: onSelectAssetPayAction
                    )
                }
                
            } header: {
                Text(model.swapFromTitle)
            } footer: {
                SwapChangeView(fromId: $fromAsset.assetId, toId: $toAsset.assetId)
                    .offset(y: Spacing.medium)
                    .frame(maxWidth: .infinity)
                    .disabled(model.isSwitchAssetButtonDisabled)
            }

            Section(model.swapToTitle) {
                if let toAsset {
                    SwapTokenView(
                        model: model.swapTokenModel(from: toAsset, type: .receive(chains: [], assetIds: [])),
                        text: $model.toValue,
                        showLoading: model.isQuoteLoading,
                        disabledTextField: true,
                        onBalanceAction: {},
                        onSelectAssetAction: onSelectAssetReceiveAction
                    )
                    .buttonStyle(.borderless)
                    .focused($focusedField, equals: .to)
                } else {
                    SwapTokenEmptyView(
                        onSelectAssetAction: onSelectAssetReceiveAction
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
                if let provider = model.providerText {
                    ListItemView(title: model.providerField, subtitle: provider)
                }
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
    private func onSelectFromBalance() {
        guard let fromAsset, let _ = toAsset else { return }
        model.setMaxFromValue(asset: fromAsset.asset, value: fromAsset.balance.available)
        focusedField = .none
    }
    
    @MainActor
    private func onSelectAssetPayAction() {
        model.onSelectAssetAction(type: .pay)
    }

    @MainActor
    private func onSelectAssetReceiveAction() {
        guard let fromAsset = fromAsset else { return }
        let (chains, assetIds) = model.getAssetsForPayAssetId(assetId: fromAsset.asset.id)
        
        model.onSelectAssetAction(type: .receive(chains: chains, assetIds: assetIds))
    }
    
    @MainActor
    private func onSelectActionButton() {
        if model.swapAvailabilityState.isError {
            fetch()
        } else {
            swap()
        }
    }

    private func onChangeTokenApprovals() {
        if tokenApprovals.isEmpty {
            focusedField = .from
        }
        fetch()
    }

    private func onChangeFromValue(_ value: String) async {
        guard let fromAsset, let toAsset else { return }
        await model.fetch(fromAssetData: fromAsset, toAsset: toAsset.asset)
    }

    private func onChangeFromAsset() {
        model.resetValues()
        focusedField = .from
        fetch()
        updateAssets()
    }

    private func onChangeToAsset() {
        model.resetToValue()
        fetch()
        updateAssets()
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
