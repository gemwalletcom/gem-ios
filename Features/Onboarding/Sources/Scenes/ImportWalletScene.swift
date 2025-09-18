// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style
import Components
import QRScanner
import Localization
import PrimitivesComponents

struct ImportWalletScene: View {
    enum Field: Int, Hashable {
        case name, input
    }
    @FocusState private var focusedField: Field?

    @State private var model: ImportWalletViewModel

    init(model: ImportWalletViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        Form {
            Section {
                FloatTextField(
                    model.walletFieldTitle,
                    text: $model.name,
                    allowClean: focusedField == .name
                )
                .focused($focusedField, equals: .name)
            }
            Section {
                VStack {
                    if model.showImportTypes {
                        Picker("", selection: $model.importType) {
                            ForEach(model.importTypes) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    HStack {
                        TextField(
                            model.importType.description,
                            text: $model.input,
                            axis: .vertical
                        )
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .lineLimit(8)
                        .keyboardType(.asciiCapable)
                        .frame(minHeight: 80, alignment: .top)
                        .focused($focusedField, equals: .input)
                        .toolbar {
                            if model.importType.showToolbar {
                                ToolbarItem(placement: .keyboard) {
                                    WordSuggestionView(
                                        words: model.wordsSuggestion,
                                        selectWord: model.onSelectWord
                                    )
                                    .padding(.horizontal, .medium)
                                }
                            }
                        }
                        .padding(.top, .small + .tiny)
                        
                        if let nameRecordViewModel = model.nameRecordViewModel, model.importType == .address {
                            NameRecordView(
                                model: nameRecordViewModel,
                                state: $model.nameResolveState,
                                address: $model.input
                            )
                        }
                    }
                    
                    HStack(alignment: .center, spacing: .medium) {
                        ListButton(
                            title: model.pasteButtonTitle,
                            image: model.pasteButtonImage,
                            action: model.onPaste
                        )
                        if model.type != .multicoin {
                            ListButton(
                                title: model.qrButtonTitle,
                                image: model.qrButtonImage,
                                action: model.onSelectScanQR
                            )
                        }
                    }
                }
                .listRowBackground(Colors.white)
            } footer: {
                if let text = model.footerText {
                    Text(text)
                }
            }
            
            Section {} header: {
                StateButton(
                    text: Localized.Wallet.Import.action,
                    type: .primary(model.buttonState),
                    action: model.onSelectActionButton
                )
                .frame(height: .scene.button.height)
                .frame(maxWidth: .scene.button.maxWidth)
            }
        }
        .listSectionSpacing(.compact)
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .navigationBarTitle(model.title)
        .alertSheet($model.isPresentingAlertMessage)
        .sheet(isPresented: $model.isPresentingScanner) {
            ScanQRCodeNavigationStack(action: model.onHandleScan)
        }
        .onChange(of: model.input, model.onChangeInput)
        .onChange(of: model.importType, model.onChangeImportType)
        .taskOnce {
            focusedField = .input
        }
    }
}
