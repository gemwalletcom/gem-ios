// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

public struct SwapScene: View {
    @FocusState private var focusedField: Bool

    @State private var model: SwapSceneViewModel

    // Update quote every 30 seconds, needed if you come back from the background.
    private let updateQuoteTimer = Timer.publish(every: 30, tolerance: 1, on: .main, in: .common).autoconnect()

    public init(model: SwapSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            swapFromSectionView
            swapToSectionView
            if model.shouldShowAdditionalInfo {
                additionalInfoSectionView
            }

            if let error = model.swapState.error {
                Section {
                    ListItemErrorView(
                        errorTitle: model.errorTitle,
                        error: error.asAnyError(asset: model.fromAsset?.asset),
                        infoAction: model.errorInfoAction
                    )
                    if let title = model.errorInfoActionButtonTitle, let action = model.errorInfoAction {
                        Button(title, action: action)
                            .foregroundStyle(Colors.blue)
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .safeAreaView {
            bottomActionView
                .confirmationDialog(
                    model.swapDetailsViewModel?.highImpactWarningTitle ?? "",
                    presenting: $model.isPresentingPriceImpactConfirmation,
                    sensoryFeedback: .warning,
                    actions: { _ in
                        Button(
                            model.buttonViewModel.title,
                            role: .destructive,
                            action: model.onSelectSwapConfirmation
                        )
                    },
                    message: {
                        Text(model.isPresentingPriceImpactConfirmation ?? "")
                    }
                )
        }
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
        .onChange(of: model.amountInputModel.text, model.onChangeFromValue)
        .onChange(of: model.pairSelectorModel, model.onChangePair)
        .onChange(of: model.selectedSwapQuote, model.onChangeSwapQuoute)
        .onReceive(updateQuoteTimer) { _ in // TODO: - create a view modifier with a timer
            model.fetch()
        }
        .onAppear {
            focusedField = true
        }
    }
}

// MARK: - UI Components

extension SwapScene {
    private var swapFromSectionView: some View {
        Section {
            SwapTokenView(
                model: model.swapTokenModel(type: .pay),
                text: $model.amountInputModel.text,
                onBalanceAction: model.onSelectFromMaxBalance,
                onSelectAssetAction: model.onSelectAssetPay
            )
            .buttonStyle(.borderless)
            .focused($focusedField)
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
            SwapTokenView(
                model: model.swapTokenModel(type: .receive(chains: [], assetIds: [])),
                text: $model.toValue,
                showLoading: model.isLoading,
                disabledTextField: true,
                onBalanceAction: {},
                onSelectAssetAction: model.onSelectAssetReceive
            )
            .buttonStyle(.borderless)
        } header: {
            Text(model.swapToTitle)
                .listRowInsets(.horizontalMediumInsets)
        }
    }

    private var additionalInfoSectionView: some View {
        Section {
            if let swapDetailsViewModel = model.swapDetailsViewModel {
                NavigationCustomLink(
                    with: SwapDetailsListView(model: swapDetailsViewModel),
                    action: model.onSelectSwapDetails
                )
            }
        }
    }

    private var swapButton: StateButton {
        StateButton(
            text: model.buttonViewModel.title,
            type: model.buttonViewModel.type,
            image: model.buttonViewModel.icon,
            infoTitle: model.buttonViewModel.infoText,
            action: onSelectActionButton
        )
    }

    private var bottomActionView: some View {
        InputAccessoryView(
            isEditing: focusedField && !model.buttonViewModel.isVisible,
            suggestions: SwapSceneViewModel.inputPercentSuggestions,
            onSelect: {
                focusedField = false
                model.onSelectPercent($0.value)
            },
            onDone: { focusedField = false },
            button: swapButton
        )
    }
}

// MARK: - Actions

extension SwapScene {
    private func onSelectActionButton() {
        focusedField = false
        model.buttonViewModel.action()
    }
}
