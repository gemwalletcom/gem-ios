// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDBQuery
import Store
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents

struct SetPriceAlertScene: View {
    @State private var model: SetPriceAlertViewModel
    
    @FocusState private var focusedField: Bool

    @Query<AssetRequest>
    private var assetData: AssetData
    
    init(model: SetPriceAlertViewModel) {
        _model = State(initialValue: model)
        _assetData = Query(constant: model.assetRequest)
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: .small) {
                    Text(model.alertDirectionTitle)
                        .textStyle(.subHeadline)

                    CurrencyInputView(
                        text: $model.state.amount,
                        config: model.currencyInputConfig(for: assetData)
                    )
                    .focused($focusedField)
                }
            }
            .cleanListRow()

            Section {
                ListAssetItemView(model: model.assetItemViewModel(for: assetData))
            }
        }
        .safeAreaView {
            safeAreaContent
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                alertTypePickerView
            }
        }
        .onChange(of: model.state.type, model.onChangeAlertType)
        .onChange(of: model.state.amount, onChangeAmount)
        .onAppear {
            focusedField = true
            model.setAlertDirection(for: assetData.price)
        }
    }
}

// MARK: - UI
extension SetPriceAlertScene {
    var alertTypePickerView: some View {
        Picker("", selection: $model.state.type) {
            Text(Localized.Asset.price)
                .tag(SetPriceAlertType.price)
            Text(Localized.Common.percentage)
                .tag(SetPriceAlertType.percentage)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }

    @ViewBuilder
    var safeAreaContent: some View {
        VStack(spacing: 0) {
            if focusedField {
                Divider()
                    .frame(height: 1 / UIScreen.main.scale)
                    .background(Colors.grayVeryLight)
                    .isVisible(focusedField)
                accessoryView
                    .padding(.small)
            } else {
                StateButton(
                    text: Localized.Transfer.confirm,
                    type: .primary(model.confirmButtonState),
                    action: confirm
                )
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .padding(.bottom, Spacing.scene.bottom)
            }
        }
        .background(focusedField ? Colors.grayBackground : .clear)
    }

    @ViewBuilder
    var accessoryView: some View {
        switch model.state.type {
        case .price:
            SuggestionsAccessoryView(
                suggestions: model.priceSuggestions(for: assetData.price),
                onSelect: onSelectPriceSuggestion,
                onDone: { focusedField = false }
            )
        case .percentage:
            SuggestionsAccessoryView(
                suggestions: model.percentageSuggestions,
                onSelect: onSelectPercentage,
                onDone: { focusedField = false }
            )
        }
    }
}

// MARK: - Actions

extension SetPriceAlertScene {
    func onChangeAmount(_: String, _: String) {
        model.setAlertDirection(for: assetData.price)
    }

    func onSelectPriceSuggestion(_ suggestion: PriceSuggestion) {
        model.onSelectPriceSuggestion(suggestion)
        focusedField = false
    }

    func onSelectPercentage(_ suggestion: PercentageSuggestion) {
        model.onSelectPercentage(suggestion)
        focusedField = false
    }

    func confirm() {
        Task {
            await model.setPriceAlert()
        }
    }
}
