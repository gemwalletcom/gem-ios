// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import PrimitivesComponents

struct VerifyPhraseWalletScene: View {
    
    @StateObject var model: VerifyPhraseViewModel

    @State private var isPresentingErrorMessage: String?

    init(model: VerifyPhraseViewModel) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        VStack(spacing: .medium) {
            List {
                CalloutView(style: .header(title: Localized.SecretPhrase.Confirm.QuickTest.title))
                    .cleanListRow()
                
                Section {
                    SecretPhraseGridView(
                        rows: model.rows,
                        highlightIndex: model.wordsIndex
                    )
                }
                .cleanListRow()
                
                Section {
                    Grid(alignment: .center) {
                        ForEach(model.rowsSections, id: \.self) { section in
                            GridRow(alignment: .center) {
                                ForEach(section) { row in
                                    if model.isVerified(index: row) {
                                        Button { } label: {
                                            Text(row.word)
                                        }
                                        .buttonStyle(.lightGray(paddingHorizontal: .small, paddingVertical: .tiny))
                                        .disabled(true)
                                        .fixedSize()
                                    } else {
                                        Button {
                                            model.pickWord(index: row)
                                        } label: {
                                            Text(row.word)
                                        }
                                        .buttonStyle(.blueGrayPressed(paddingHorizontal: .small, paddingVertical: .tiny))
                                        .fixedSize()
                                    }
                                }
                            }
                        }
                    }
                }
                .cleanListRow()
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))

            StateButton(
                text: Localized.Common.continue,
                type: .primary(model.buttonState),
                action: onImportWallet
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.createWallet("")), message: Text($0))
        }
    }

}

// MARK: - Actions

extension VerifyPhraseWalletScene {
    func onImportWallet() {
        model.buttonState = .loading(showProgress: true)

        Task {
            try await Task.sleep(for: .milliseconds(50))
            do {
                try await MainActor.run {
                    try model.importWallet()
                }
            } catch {
                await MainActor.run {
                    isPresentingErrorMessage = error.localizedDescription
                    model.buttonState = .normal
                }
            }
        }
    }
}
