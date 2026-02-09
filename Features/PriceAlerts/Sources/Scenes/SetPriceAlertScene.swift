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

    var confirmButton: StateButton {
        StateButton(
            text: Localized.Transfer.confirm,
            type: .primary(model.confirmButtonState),
            action: confirm
        )
    }

    @ViewBuilder
    var safeAreaContent: some View {
        switch model.state.type {
        case .price:
            inputAccessoryView(model.priceSuggestions(for: assetData.price))
        case .percentage:
            inputAccessoryView(model.percentageSuggestions(for: assetData.price))
        }
    }

    private func inputAccessoryView(_ suggestions: [some SuggestionViewable]) -> some View {
        InputAccessoryView(
            isEditing: focusedField && model.state.amount.isEmpty,
            suggestions: suggestions,
            onSelect: onSelectSuggestion,
            onDone: { focusedField = false },
            button: confirmButton
        )
    }
}

// MARK: - Actions

extension SetPriceAlertScene {
    func onChangeAmount(_: String, _: String) {
        model.setAlertDirection(for: assetData.price)
    }

    func onSelectSuggestion(_ suggestion: some SuggestionViewable) {
        model.onSelectSuggestion(suggestion)
    }

    func confirm() {
        Task {
            await model.setPriceAlert()
        }
    }
}
