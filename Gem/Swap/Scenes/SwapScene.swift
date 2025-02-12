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
import PrimitivesComponents

struct SwapScene: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.nodeService) private var nodeService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.walletsService) private var walletsService

    enum Field: Int, Hashable {
        case from, to
    }
    @FocusState private var focusedField: Field?

    @Query<AssetRequestOptional>
    private var fromAsset: AssetData?

    @Query<AssetRequestOptional>
    private var toAsset: AssetData?

    @State private var model: SwapViewModel

    // Update quote every 30 seconds, needed if you come back from the background.
    private let updateQuoteTimer = Timer.publish(every: 30, tolerance: 1, on: .main, in: .common).autoconnect()

    init(
        model: SwapViewModel
    ) {
        _model = State(initialValue: model)
        _fromAsset = Query(model.fromAssetRequest)
        _toAsset = Query(model.toAssetRequest)
    }

    var body: some View {
        VStack {
            swapList
            Spacer()
            VStack {
                if let fromAsset {
                    StateButton(
                        text: model.actionButtonTitle(fromAsset: fromAsset.asset),
                        viewState: model.actionButtonState,
                        disabledRule: model.shouldDisableActionButton(fromAsset: fromAsset.asset),
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
            value: model.swapState.fetch,
            interval: model.swapState.fetch.delay,
            action: model.onFetchStateChange
        )
        .debounce(
            value: model.assetIds(fromAsset, toAsset),
            initial: true,
            interval: .none,
            action: model.onAssetIdsChange
        )
        .onChange(of: model.fromValue, onChangeFromValue)
        .onChange(of: fromAsset, onChangeFromAsset)
        .onChange(of: toAsset, onChangeToAsset)
        .onChange(of: model.pairSelectorModel.fromAssetId) { _, new in
            $fromAsset.assetId.wrappedValue = new?.identifier
        }
        .onChange(of: model.pairSelectorModel.toAssetId) { _, new in
            $toAsset.assetId.wrappedValue = new?.identifier
        }
        .onReceive(updateQuoteTimer) { _ in // TODO: - create a view modifier with a timer
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
                        showLoading: model.showToValueLoading(),
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
                if let provider = model.providerText {
                    ListItemImageView(
                        title: model.providerField,
                        subtitle: provider,
                        assetImage: model.providerImage
                    )
                }

                if let viewModel = model.priceImpactViewModel(fromAsset, toAsset) {
                    PriceImpactView(model: viewModel)
                }
            }

            if case let .error(error) = model.swapState.availability {
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

    private func onSelectAssetPayAction() {
        model.onSelectAssetAction(type: .pay)
    }

    private func onSelectAssetReceiveAction() {
        guard let fromAsset = fromAsset else { return }
        let (chains, assetIds) = model.getAssetsForPayAssetId(assetId: fromAsset.asset.id)
        
        model.onSelectAssetAction(type: .receive(chains: chains, assetIds: assetIds))
    }

    private func onSelectActionButton() {
        if model.swapState.availability.isError {
            fetch()
        } else {
            swap()
        }
    }

    private func onChangeFromValue(_: String, _: String) {
        fetch(delay: SwapViewModel.quoteTaskDebounceTimeout)
    }

    private func onChangeFromAsset(_: AssetData?, _: AssetData?) {
        model.resetValues()
        focusedField = .from
        fetch()
    }

    private func onChangeToAsset(_: AssetData?, _: AssetData?) {
        model.resetToValue()
        fetch()
    }
}

// MARK: - Effects

extension SwapScene {
    private func fetch(delay: Duration? = nil) {
        let input = SwapQuoteInput(
            fromAsset: fromAsset,
            toAsset: toAsset,
            amount: model.fromValue
        )
        model.swapState.fetch = .fetch(input: input, delay: delay)
    }

    func swap() {
        Task {
            guard let fromAsset, let toAsset else { return }
            await model.swap(fromAsset: fromAsset.asset, toAsset: toAsset.asset)
        }
    }
}
