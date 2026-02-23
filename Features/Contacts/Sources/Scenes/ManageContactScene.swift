// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents
import Style
import Localization

public struct ManageContactScene: View {

    @Environment(\.dismiss) private var dismiss

    @Binding private var model: ManageContactViewModel

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case name
        case description
    }

    public init(model: Binding<ManageContactViewModel>) {
        _model = model
    }

    public var body: some View {
        List {
            contactSection
            addressesSection
        }
        .safeAreaButton {
            StateButton(
                text: model.buttonTitle,
                type: .primary(model.buttonState),
                action: onSave
            )
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onAddAddress) {
                    Images.System.plus
                }
            }
        }
        .onAppear {
            if model.isAddMode {
                focusedField = .name
            }
        }
    }
}

// MARK: - UI Components

extension ManageContactScene {
    private var contactSection: some View {
        Section {
            InputValidationField(
                model: $model.nameInputModel,
                placeholder: model.nameTitle,
                allowClean: true
            )
            .focused($focusedField, equals: .name)
            .textInputAutocapitalization(.words)

            FloatTextField(
                model.descriptionTitle,
                text: $model.description,
                allowClean: true
            )
            .focused($focusedField, equals: .description)
        } header: {
            Text(model.contactSectionTitle)
        }
    }

    private var addressesSection: some View {
        Section {
            ForEach(model.addresses, id: \.id) { address in
                NavigationCustomLink(
                    with: ListItemView(model: model.listItemModel(for: address)),
                    action: { model.isPresentingContactAddress = address }
                )
            }
            .onDelete(perform: model.deleteAddress)

            Button(action: onAddAddress) {
                HStack {
                    Images.System.plus
                    Text(Localized.Common.address)
                }
            }
        } header: {
            Text(model.addressesSectionTitle)
        }
    }
}

// MARK: - Actions

extension ManageContactScene {
    private func onAddAddress() {
        focusedField = .none
        model.isPresentingAddAddress = true
    }

    private func onSave() {
        focusedField = .none
        model.onSave()
        if model.shouldDismissOnSave {
            dismiss()
        }
    }
}

