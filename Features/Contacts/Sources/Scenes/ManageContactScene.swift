// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents
import Style
import GemstonePrimitives

public struct ManageContactScene: View {

    @Environment(\.dismiss) private var dismiss

    @Binding private var model: ManageContactViewModel

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case name
        case address
        case memo
        case description
    }

    public init(model: Binding<ManageContactViewModel>) {
        _model = model
    }

    public var body: some View {
        List {
            chainSection
            nameSection
            addressSection
            if model.showMemo {
                memoSection
            }
            descriptionSection
        }
        .safeAreaButton {
            StateButton(
                text: model.saveButtonTitle,
                type: .primary(model.saveButtonState),
                action: onSave
            )
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - UI Components

extension ManageContactScene {
    private var chainSection: some View {
        Section(model.networkTitle) {
            if let chain = model.chain {
                NavigationLink(value: Scenes.NetworksSelector()) {
                    ChainView(model: ChainViewModel(chain: chain))
                }
            }
        }
    }

    private var nameSection: some View {
        Section {
            InputValidationField(
                model: $model.nameInputModel,
                placeholder: model.nameTitle,
                allowClean: true
            )
            .focused($focusedField, equals: .name)
            .textInputAutocapitalization(.words)
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
                        ListButton(
                            image: model.pasteImage,
                            action: onSelectPaste
                        )
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
                allowClean: focusedField == .memo
            )
            .focused($focusedField, equals: .memo)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
    }

    private var descriptionSection: some View {
        Section {
            FloatTextField(
                model.descriptionTitle,
                text: $model.description,
                allowClean: focusedField == .description
            )
            .focused($focusedField, equals: .description)
        }
    }
}

// MARK: - Actions

extension ManageContactScene {
    private func onSelectPaste() {
        model.onSelectPaste()
        focusedField = nil
    }

    private func onSave() {
        focusedField = nil
        model.onSave()
        dismiss()
    }
}
