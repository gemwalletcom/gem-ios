// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUICore
import SwiftUI
import PrimitivesComponents
import Components
import Primitives
import Style
import Localization
import NameResolver

public struct AddContactAddressScene: View {
    
    @State private var model: AddContactAddressViewModel
    @State private var isPresentingErrorMessage: String?
    @Binding private var isPresentingScanner: Bool

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case address
        case name
        case description
    }
    
    public init(
        model: AddContactAddressViewModel,
        isPresentingScanner: Binding<Bool>
    ) {
        _isPresentingScanner = isPresentingScanner
        _model = State(initialValue: model)
    }
    
    @ViewBuilder
    public var body: some View {
        VStack {
            List {
                Section {
                    if let chain = model.input.chain.value {
                        NavigationLink(value: Scenes.NetworksSelector()) {
                            ChainView(model: ChainViewModel(chain: chain))
                        }
                    } else {
                        NavigationLink(value: Scenes.NetworksSelector()) {
                            ListItemView(title: "Select chain")
                        }
                    }
                    if let chain = model.input.chain.value {
                        FloatTextField(model.addressTextFieldTitle, text: $model.projectedValue.input.address.value, allowClean: false) {
                            HStack(spacing: .large/2) {
                                NameRecordView(
                                    model: NameRecordViewModel(chain: chain),
                                    state: $model.nameResolveState,
                                    address: $model.input.address.value
                                )
                                ListButton(image: Images.System.paste) {
                                    onSelectPaste()
                                }
                                ListButton(image: Images.System.qrCode) {
                                    onSelectScan()
                                }
                            }
                        }
                        .focused($focusedField, equals: .address)
                        .keyboardType(.alphabet)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .truncationMode(.middle)
                    }
                    if model.showMemo {
                        FloatTextField(model.memoTextFieldTitle, text: $model.projectedValue.input.memo.value)
                            .focused($focusedField, equals: .name)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                    }
                }
                
            }
            Spacer()
            StateButton(
                text: model.actionButtonTitle,
                styleState: .normal,
                action: onSelectConfirm
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .onAppear {
            focusedField = .address
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(Localized.Common.cancel) {
                    model.onComplete?()
                }.bold()
            }
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .listSectionSpacing(.compact)
        .alert(
            "",
            isPresented: $isPresentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(isPresentingErrorMessage ?? "")
            }
        )
    }
}

// MARK: - Actions

extension AddContactAddressScene {
    private func onSelectScan() {
        isPresentingScanner = true
    }
    
    private func onSelectPaste() {
        guard let address = UIPasteboard.general.string else { return }
        model.input.address.value = address
    }
    
    private func onSelectConfirm() {
        do {
            try model.confirmAddContact()
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }
}
