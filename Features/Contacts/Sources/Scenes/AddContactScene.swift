// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUICore
import SwiftUI
import PrimitivesComponents
import Components
import Primitives
import Style
import Localization

public struct AddContactScene: View {
    
    @State private var model: AddContactViewModel
    @State private var presentingErrorMessage: String?

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case address
        case name
        case description
    }
    
    public init(model: AddContactViewModel) {
        _model = State(initialValue: model)
    }
    
    @ViewBuilder
    public var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(model.nameTitleField, text: $model.projectedValue.input.name.value)
                        .focused($focusedField, equals: .name)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                    FloatTextField(model.descriptionTitleField, text: $model.projectedValue.input.description.value)
                        .focused($focusedField, equals: .name)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                }
                
            }
            Spacer()
            StateButton(
                text: model.actionButtonTitlte,
                viewState: model.state,
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
            isPresented: $presentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(presentingErrorMessage ?? "")
            }
        )
    }
}

// MARK: - Actions

extension AddContactScene {
    private func onSelectConfirm() {
        do {
            try model.confirmAddContact()
        } catch {
            presentingErrorMessage = error.localizedDescription
        }
    }
}
