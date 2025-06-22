// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

public struct SwapScene: View {
    enum Field: Int, Hashable {
        case from, to
    }
    @FocusState private var focusedField: Field?

    @State private var model: SwapSceneViewModel

    // Update quote every 30 seconds, needed if you come back from the background.
    private let updateQuoteTimer = Timer.publish(every: 30, tolerance: 1, on: .main, in: .common).autoconnect()

    public init(model: SwapSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            swapList
                .padding(.bottom, .scene.button.height)
            bottomActionView
        }
        .confirmationDialog(
            model.priceImpactModel?.highImpactWarningTitle ?? "",
            presenting: $model.isPresentingPriceImpactConfirmation,
            sensoryFeedback: .warning,
            actions: { _ in
                Button(
                    model.actionButtonTitle,
                    role: .destructive,
                    action: model.onSelectSwapConfirmation
                )
            },
            message: {
                Text(model.isPresentingPriceImpactConfirmation ?? "")
            }
        )
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .onChangeObserveQuery(
            request: $model.fromAssetRequest,
            value: $model.fromAsset,
            action: model.onChangeFromAsset
        )
        .onChangeObserveQuery(
            request: $model.toAssetRequest,
            value: $model.toAsset,
            action: model.onChangeToAsset
        )
        .debounce(
            value: model.swapState.fetch,
            interval: model.swapState.fetch.delay,
            action: model.onFetchStateChange
        )
        .debounce(
            value: model.assetIds,
            initial: true,
            interval: .none,
            action: model.onAssetIdsChange
        )
        .onChange(of: model.fromValue, model.onChangeFromValue)
        .onChange(of: model.pairSelectorModel, model.onChangePair)
        .onChange(of: model.selectedSwapQuote, model.onChangeSwapQuoute)
        .onChange(of: model.focusField, onChangeFocus)
        .onReceive(updateQuoteTimer) { _ in // TODO: - create a view modifier with a timer
            model.fetch()
        }
        .onAppear {
            if model.toValue.isEmpty {
                model.focusField = .from
            }
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

            if let error = model.swapState.error {
                ListItemErrorView(errorTitle: model.errorTitle, error: error)
            }
        }
    }
    
    private var swapFromSectionView: some View {
        Section {
            if let swapModel = model.swapTokenModel(type: .pay) {
                SwapTokenView(
                    model: swapModel,
                    text: $model.fromValue,
                    onBalanceAction: model.onSelectFromMaxBalance,
                    onSelectAssetAction: model.onSelectAssetPay
                )
                .buttonStyle(.borderless)
                .focused($focusedField, equals: .from)
            } else {
                SwapTokenEmptyView(
                    onSelectAssetAction: model.onSelectAssetPay
                )
            }
        } header: {
            Text(model.swapFromTitle)
                .listRowInsets(.horizontalMediumInsets)
        } footer: {
            SwapChangeView(
                fromId: $model.pairSelectorModel.fromAssetId,
                toId: $model.pairSelectorModel.toAssetId
            )
                .padding(.top, .small)
                .frame(maxWidth: .infinity)
                .disabled(model.isSwitchAssetButtonDisabled)
                .textCase(nil)
                .listRowSeparator(.hidden)
                .listRowInsets(.horizontalMediumInsets)
        }
    }
    
    private var swapToSectionView: some View {
        Section {
            if let swapModel = model.swapTokenModel(type: .receive(chains: [], assetIds: [])) {
                SwapTokenView(
                    model: swapModel,
                    text: $model.toValue,
                    showLoading: model.isLoading,
                    disabledTextField: true,
                    onBalanceAction: {},
                    onSelectAssetAction: model.onSelectAssetReceive
                )
                .buttonStyle(.borderless)
                .focused($focusedField, equals: .to)
            } else {
                SwapTokenEmptyView(
                    onSelectAssetAction: model.onSelectAssetReceive
                )
            }
        } header: {
            Text(model.swapToTitle)
                .listRowInsets(.horizontalMediumInsets)
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
                if model.allowSelectProvider {
                    NavigationCustomLink(
                        with: view,
                        action: model.onSelectProviderSelector
                    )
                } else {
                    view
                }
            }
            
            if let swapEstimation = model.swapEstimationText {
                ListItemView(title: model.swapEstimationTitle, subtitle: swapEstimation)
            }
            
            if let rateText = model.rateText {
                ListItemImageView(
                    title: model.rateTitle,
                    subtitle: rateText,
                    assetImage: .none
                )
            }

            if let viewModel = model.priceImpactModel {
                PriceImpactView(
                    model: viewModel,
                    infoAction: model.onSelectPriceImpactInfo
                )
            }
        }
    }
    
    private var buttonView: some View {
        VStack {
            StateButton(
                text: model.actionButtonTitle,
                variant: .primary(model.actionButtonState, disabledRule: model.shouldDisableActionButton),
                action: model.onSelectActionButton
            )
        }
        .frame(maxWidth: Spacing.scene.button.maxWidth)
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
                } else if focusedField == .from {
                    PercentageAccessoryView(
                        onSelectPercent: model.onSelectPercent,
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
    private func onChangeFocus(_ _: Field?, _ newField: Field?) {
        focusedField = newField
    }
}
