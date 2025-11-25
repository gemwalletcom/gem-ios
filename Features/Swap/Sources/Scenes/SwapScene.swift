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
        List {
            swapFromSectionView
            swapToSectionView
            if model.shouldShowAdditionalInfo {
                additionalInfoSectionView
            }

            if let error = model.swapState.error {
                ListItemErrorView(errorTitle: model.errorTitle, error: error, infoAction: model.errorInfoAction)
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
    private var swapFromSectionView: some View {
        Section {
            SwapTokenView(
                model: model.swapTokenModel(type: .pay),
                text: $model.amountInputModel.text,
                onBalanceAction: model.onSelectFromMaxBalance,
                onSelectAssetAction: model.onSelectAssetPay
            )
            .buttonStyle(.borderless)
            .focused($focusedField, equals: .from)
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
            .focused($focusedField, equals: .to)
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
    
    private var buttonView: some View {
        VStack {
            StateButton(model.buttonViewModel)
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
                if model.buttonViewModel.isVisible {
                    buttonView
                } else if focusedField == .from {
                    PercentageAccessoryView(
                        percents: SwapSceneViewModel.inputPercents,
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
