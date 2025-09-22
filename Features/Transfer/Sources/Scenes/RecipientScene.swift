// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import PrimitivesComponents

struct RecipientScene: View {
    enum Field: Int, Hashable, Identifiable {
        case address
        case memo
        var id: String { String(rawValue) }
    }

    @FocusState private var focusedField: Field?

    private var model: RecipientSceneViewModel

    init(model: RecipientSceneViewModel) {
        self.model = model
    }

    var body: some View {
        @Bindable var model = model
        List {
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
                            with: ListItemView(title: item.value.name),
                            action: { model.onSelectRecipient(item.value) }
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
        .safeAreaView {
            StateButton(
                text: model.actionButtonTitle,
                type: .primary(model.actionButtonState),
                action: model.onContinue
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .navigationTitle(model.tittle)
        .onChange(of: model.addressInputModel.text, model.onChangeAddressText)
        .onChange(of: model.nameResolveState, model.onChangeNameResolverState)
    }
}
