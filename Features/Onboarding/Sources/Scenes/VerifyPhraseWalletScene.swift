// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import PrimitivesComponents

struct VerifyPhraseWalletScene: View {
    
    @StateObject var model: VerifyPhraseViewModel

    @State private var isPresentingErrorMessage: String?
    @Binding private var isPresentingWallets: Bool

    init(
        model: VerifyPhraseViewModel,
        isPresentingWallets: Binding<Bool>
    ) {
        _model = StateObject(wrappedValue: model)
        _isPresentingWallets = isPresentingWallets
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: .medium) {
                OnboardingHeaderTitle(title: Localized.SecretPhrase.Confirm.QuickTest.title, alignment: .center)
                
                SecretPhraseGridView(rows: model.rows, highlightIndex: model.wordsIndex)
                    .padding(.top, .small)
                
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
                .padding(.top, .small)
                
                Spacer()
                StateButton(
                    text: Localized.Common.continue,
                    styleState: model.buttonState,
                    action: onImportWallet
                )
            }
            .frame(maxWidth: .scene.content.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
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
                    let _ = try model.importWallet()
                    isPresentingWallets = false
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
