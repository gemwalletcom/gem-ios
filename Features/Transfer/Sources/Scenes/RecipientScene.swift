// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import PrimitivesComponents
import Store

public struct RecipientScene: View {
    public enum Field: Int, Hashable, Identifiable {
        case address
        case memo
        public var id: String { String(rawValue) }
    }

    @FocusState private var focusedField: Field?

    private var model: RecipientSceneViewModel

    public init(model: RecipientSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        @Bindable var model = model
        List {
            Section { } header: {
                AssetImageTitleView(model: model.assetImageTitleModel)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, .small)
            }
            .cleanListRow()

            Section {
                InputValidationField(
                    model: $model.addressInputModel,
                    placeholder: model.recipientField,
                    allowClean: true,
                    trailingView: {
                        HStack(spacing: .large/2) {
                            NameRecordView(
                                model: model.nameRecordViewModel,
                                state: $model.nameResolveState,
                                address: $model.addressInputModel.text
                            )
                            if model.shouldShowInputActions {
                                ListButton(
                                    image: model.pasteImage,
                                    action: { model.onSelectPaste(field: .address) }
                                )
                                ListButton(
                                    image: model.qrImage,
                                    action: { model.onSelectScan(field: .address) }
                                )
                            }
                        }
                    }
                )
                .focused($focusedField, equals: .address)
                .keyboardType(.alphabet)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            
            if model.showMemo {
                Section {
                    FloatTextField(
                        model.memoField,
                        text: $model.memo,
                        allowClean: focusedField == .memo,
                        trailingView: {
                            ListButton(
                                image: model.qrImage,
                                action: { model.onSelectScan(field: .memo) }
                            )
                        }
                    )
                    .focused($focusedField, equals: .memo)
                    .keyboardType(.alphabet)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
            }
            
            ForEach(model.recipientSections) { section in
                Section {
                    ForEach(section.values) { item in
                        NavigationCustomLink(
                            with: ListItemView(title: item.title ?? item.value.name, subtitle: item.subtitle),
                            action: { onSelectRecipient(item.value) }
                        )
                    }
                } header: {
                    HStack {
                        section.image
                            .frame(size: .image.small)
                        Text(section.section)
                    }
                }
            }
        }
        .safeAreaButton {
            StateButton(
                text: model.actionButtonTitle,
                type: .primary(model.actionButtonState),
                action: onSelectContinue
            )
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listSectionSpacing(.compact)
        .navigationTitle(model.tittle)
        .bindQuery(model.contactsQuery)
        .onChange(of: model.addressInputModel.text, model.onChangeAddressText)
        .onChange(of: model.nameResolveState, model.onChangeNameResolverState)
    }
}

// MARK: - Actions

extension RecipientScene {
    private func onSelectRecipient(_ recipient: RecipientAddress) {
        focusedField = nil
        model.onSelectRecipient(recipient)
    }

    private func onSelectContinue() {
        focusedField = nil
        model.onContinue()
    }
}
