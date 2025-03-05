// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import GRDBQuery
import Components
import Style
import BigInt
import ChainService
import struct Swap.SwapTokenEmptyView
import struct Swap.SwapChangeView
import PrimitivesComponents
import Swap
import InfoSheet
import Gemstone

struct SwapScene: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.nodeService) private var nodeService
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
    
    @State private var isPresentingInfoSheet: InfoSheetType? = .none
    @Binding private var isPresentingAssetSwapType: SelectAssetSwapType?
    @Binding private var isPresentingSwapProviderSelect: Asset?
    private let onTransferAction: TransferDataAction

    // Update quote every 30 seconds, needed if you come back from the background.
    private let updateQuoteTimer = Timer.publish(every: 30, tolerance: 1, on: .main, in: .common).autoconnect()

    init(
        model: SwapViewModel,
        isPresentingAssetSwapType: Binding<SelectAssetSwapType?>,
        isPresentingSwapProviderSelect: Binding<Asset?>,
        onTransferAction: TransferDataAction
    ) {
        _model = State(initialValue: model)
        _fromAsset = Query(model.fromAssetRequest)
        _toAsset = Query(model.toAssetRequest)
        _isPresentingAssetSwapType = isPresentingAssetSwapType
        _isPresentingSwapProviderSelect = isPresentingSwapProviderSelect
        self.onTransferAction = onTransferAction
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                swapList
            }
            bottomActionView
        }
        .navigationTitle(model.title)
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
        .onChange(of: model.selectedSwapQuote, onChangeSelectedQuote)
        .onReceive(updateQuoteTimer) { _ in // TODO: - create a view modifier with a timer
            fetch()
        }
        .onAppear {
            if model.toValue.isEmpty {
                focusedField = .from
            }
        }
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
    }
}

// MARK: - UI Components

extension SwapScene {
    private var swapList: some View {
        List {
            swapFromSectionView
            swapToSectionView
            additionalInfoSectionView

            if case let .error(error) = model.swapState.availability {
                ListItemErrorView(errorTitle: model.errorTitle, error: error)
            }
        }
    }
    
    private var swapFromSectionView: some View {
        Section {
            if let fromAsset {
                SwapTokenView(
                    model: model.swapTokenModel(from: fromAsset, type: .pay),
                    text: $model.fromValue,
                    onBalanceAction: onSelectFromMaxBalance,
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
                .offset(y: Spacing.small + Spacing.tiny)
                .frame(maxWidth: .infinity)
                .disabled(model.isSwitchAssetButtonDisabled)
                .textCase(nil)
                .listRowSeparator(.hidden)
                .listRowInsets(.zero)
        }
    }
    
    private var swapToSectionView: some View {
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
    }
    
    private var additionalInfoSectionView: some View {
        Section {
            if let provider = model.providerText {
                let view = ListItemImageView(
                    title: model.providerField,
                    subtitle: provider,
                    assetImage: model.providerImage
                )
                if model.allowSelectProvider, let toAsset {
                    NavigationCustomLink(with: view) {
                        isPresentingSwapProviderSelect = toAsset.asset
                    }
                } else {
                    view
                }
            }

            if let viewModel = model.priceImpactViewModel(fromAsset, toAsset) {
                PriceImpactView(model: viewModel) {
                    isPresentingInfoSheet = .priceImpact
                }
            }
        }
    }
    
    private var buttonView: some View {
        VStack {
            if let fromAsset {
                StateButton(
                    text: model.actionButtonTitle(),
                    viewState: model.actionButtonState,
                    disabledRule: model.shouldDisableActionButton(fromAsset: fromAsset.asset),
                    action: onSelectActionButton
                )
            }
        }
    }
    
    @ViewBuilder
    private var bottomActionView: some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: 1 / UIScreen.main.scale)
                .background(Colors.grayVeryLight)
                .isVisible(focusedField == .from)

            Group {
                if model.isVisibleActionButton {
                    buttonView
                        .frame(height: focusedField == .from ? Spacing.scene.button.accessoryHeight : Spacing.scene.button.height)
                } else if focusedField == .from {
                    PercentageAccessoryView(
                        onSelectPercent: onSelectPercent,
                        onDone: { focusedField = nil }
                    )
                }
            }
            .padding(.small)
        }
        .background(Colors.grayBackground)
    }
}

// MARK: - Actions

extension SwapScene {
    private func onSelectFromMaxBalance() {
        onSelectPercent(100)
    }
    
    private func onSelectPercent(_ percent: Int) {
        model.setFromValue(asset: fromAsset, percent: percent)
        focusedField = .none
    }

    private func onSelectAssetPayAction() {
        isPresentingAssetSwapType = .pay
    }

    private func onSelectAssetReceiveAction() {
        guard let fromAsset = fromAsset else { return }
        let (chains, assetIds) = model.getAssetsForPayAssetId(assetId: fromAsset.asset.id)
        isPresentingAssetSwapType = .receive(chains: chains, assetIds: assetIds)
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
        model.setSelectedSwapQuote(nil)
        focusedField = .from
        fetch()
    }

    private func onChangeToAsset(_: AssetData?, _: AssetData?) {
        model.resetToValue()
        model.setSelectedSwapQuote(nil)
        fetch()
    }
    
    private func onChangeSelectedQuote(_: SwapQuote?, quote: SwapQuote?) {
        guard let quote, let toAsset else { return }
        model.onSelectQuote(quote, asset: toAsset.asset)
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
            guard
                let fromAsset,
                let toAsset,
                let swapData = await model.swapData(fromAsset: fromAsset.asset, toAsset: toAsset.asset)
            else {
                return
            }
            onTransferAction?(swapData)
        }
    }
}
