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

public struct SetPriceAlertScene: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: SetPriceAlertViewModel
    @State private var isPresentingToast: Bool = false
    
    @FocusState private var focusedField: Bool

    @Query<AssetRequest>
    private var assetData: AssetData
    
    public init(model: SetPriceAlertViewModel) {
        _model = State(initialValue: model)
        _assetData = Query(constant: model.assetRequest)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Text(model.alertDirectionTitle)
                .textStyle(.subheadline)
                .padding(.bottom, Spacing.tiny)
            
            CurrencyInputView(
                text: $model.state.amount,
                config: model.currencyInputConfig(for: assetData)
            )
            .focused($focusedField)
            
            if model.showPercentageAlertDirectionPicker {
                percentageDirectionPickerView
                    .padding(.top, Spacing.medium)
            }
            
            Spacer()
            
            StateButton(
                text: Localized.Transfer.confirm,
                styleState: model.confirmButtonState,
                action: confirm
            )
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .toolbar {
            ToolbarItem(placement: .principal) {
                alertTypePickerView
            }
        }
        .onChange(of: assetData, initial: true, model.setPrice)
        .onChange(of: model.state.type, model.onChangeAlertType)
        .onChange(of: model.state.amount, onChangeAmount)
        .onChange(of: isPresentingToast, onChangeIsPresentingToast)
        .onAppear { focusedField = true }
        .toast(
            isPresenting: $isPresentingToast,
            title: Localized.PriceAlerts.enabledFor(assetData.asset.name),
            systemImage: SystemImage.checkmark
        )
    }
}

// MARK: - UI
extension SetPriceAlertScene {
    var alertTypePickerView: some View {
        Picker("", selection: $model.state.type) {
            Text("Price")
                .tag(SetPriceAlertType.price)
            Text("Percentage")
                .tag(SetPriceAlertType.percentage)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
    
    var percentageDirectionPickerView: some View {
        Picker("", selection: $model.state.alertDirection) {
            Text("Increase")
                .tag(PriceAlertDirection.up)
            Text("Decrease")
                .tag(PriceAlertDirection.down)
        }
        .pickerStyle(.segmented)
        .fixedSize()
    }
}

// MARK: - Actions

extension SetPriceAlertScene {
    func onChangeAmount(_: String, _: String) {
        model.setAlertDirection(for: assetData.price)
    }
    
    func confirm() {
        Task {
            do {
                try await model.setPriceAlert()
                isPresentingToast = true
            } catch {
                print(error)
            }
        }
    }
    
    func onChangeIsPresentingToast(_: Bool, newValue: Bool) {
        if newValue == false {
            dismiss()
        }
    }
}
