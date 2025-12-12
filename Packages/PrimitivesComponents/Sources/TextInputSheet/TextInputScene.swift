// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import Components

public struct TextInputScene<ViewModel: TextInputViewModelProtocol>: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: ViewModel
    @FocusState private var isFocused: Bool

    private let onComplete: () -> Void

    public init(model: ViewModel, onComplete: @escaping () -> Void) {
        _model = State(initialValue: model)
        self.onComplete = onComplete
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    FloatTextField(model.placeholder, text: $model.text)
                        .focused($isFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit(onSubmit)
                } footer: {
                    if let footer = model.footer {
                        Text(footer)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .contentMargins(.top, .scene.top, for: .scrollContent)
            .navigationTitle(model.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Localized.Common.cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if model.isLoading {
                        ProgressView()
                    } else {
                        Button(Localized.Common.done, action: onSubmit)
                            .bold()
                            .disabled(model.isActionDisabled)
                    }
                }
            }
            .onAppear {
                isFocused = true
            }
            .alert(
                Localized.Errors.errorOccured,
                isPresented: Binding(
                    get: { model.errorMessage != nil },
                    set: { if !$0 { model.errorMessage = nil } }
                )
            ) {
                Button(Localized.Common.done, role: .cancel) {}
            } message: {
                if let error = model.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Actions

extension TextInputScene {
    private func onCancel() {
        dismiss()
    }

    private func onSubmit() {
        Task {
            model.errorMessage = nil
            await model.action()
            if model.errorMessage == nil {
                onComplete()
                dismiss()
            }
        }
    }
}
