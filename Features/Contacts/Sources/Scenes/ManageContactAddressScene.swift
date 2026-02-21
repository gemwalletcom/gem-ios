// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents
import Style
import GemstonePrimitives
import QRScanner

public struct ManageContactAddressScene: View {

    @Binding private var model: ManageContactAddressViewModel

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case address
        case memo
    }

    public init(model: Binding<ManageContactAddressViewModel>) {
        _model = model
    }

    public var body: some View {
        List {
            chainSection
            addressSection
            if model.showMemo {
                memoSection
            }
        }
        .safeAreaButton {
            StateButton(
                text: model.buttonTitle,
                type: .primary(model.buttonState),
                action: onComplete
            )
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $model.isPresentingScanner) {
            ScanQRCodeNavigationStack(action: onScan)
        }
    }
}

// MARK: - UI Components

extension ManageContactAddressScene {
    private var chainSection: some View {
        Section(model.networkTitle) {
            NavigationLink(value: Scenes.NetworksSelector()) {
                ChainView(model: ChainViewModel(chain: model.chain))
            }
        }
    }

    private var addressSection: some View {
        Section {
            InputValidationField(
                model: $model.addressInputModel,
                placeholder: model.addressTitle,
                allowClean: true,
                trailingView: {
                    if model.shouldShowInputActions {
                        HStack(spacing: .medium) {
                            ListButton(image: model.pasteImage, action: onSelectPaste)
                            ListButton(image: model.qrImage, action: onSelectScan)
                        }
                    }
                }
            )
            .focused($focusedField, equals: .address)
            .keyboardType(.alphabet)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
    }

    private var memoSection: some View {
        Section {
            FloatTextField(
                model.memoTitle,
                text: $model.memo,
                allowClean: true
            )
            .focused($focusedField, equals: .memo)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
    }
}

// MARK: - Actions

extension ManageContactAddressScene {
    private func onSelectPaste() {
        model.onSelectPaste()
        focusedField = nil
    }

    private func onSelectScan() {
        model.onSelectScan()
    }

    private func onScan(_ result: String) {
        model.onHandleScan(result)
        focusedField = nil
    }

    private func onComplete() {
        focusedField = nil
        model.complete()
    }
}
