// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct VerifyPhraseWalletScene: View {
    
    @StateObject var model: VerifyPhraseViewModel

    @Environment(\.isWalletsPresented) private var isWalletsPresented
    
    @State private var isPresentingErrorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.medium) {
                OnboardingHeaderTitle(title: Localized.SecretPhrase.Confirm.QuickTest.title)
                
                SecretPhraseGridView(rows: model.rows, highlightIndex: model.wordsIndex)
                    .padding(.top, Spacing.small)
                
                Grid(alignment: .center) {
                    ForEach(model.rowsSections, id: \.self) { section in
                        GridRow(alignment: .center) {
                            ForEach(section) { row in
                                if model.isVerified(word: row.word) {
                                    Button { } label: {
                                        Text(row.word)
                                    }
                                    .buttonStyle(.lightGray(paddingHorizontal: Spacing.small, paddingVertical: Spacing.tiny))
                                    .disabled(true)
                                    .fixedSize()
                                } else {
                                    Button {
                                        model.pickWord(index: row)
                                    } label: {
                                        Text(row.word)
                                    }
                                    .buttonStyle(.blueGrayPressed(paddingHorizontal: Spacing.small, paddingVertical: Spacing.tiny))
                                    .fixedSize()
                                }
                            }
                        }
                    }
                }
                .padding(.top, Spacing.small)
                
                Spacer()
                StateButton(
                    text: Localized.Common.continue,
                    styleState: model.buttonState,
                    action: onImportWallet
                )
            }
            .frame(maxWidth: Spacing.scene.content.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .navigationTitle(model.title)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.createWallet("")), message: Text($0))
        }
    }

}

// MARK: - Actions

extension VerifyPhraseWalletScene {
    func onImportWallet() {
        model.buttonState = .loading

        Task {
            //TODO: For some reason loading does not start unless there is a delay.
            try await Task.sleep(for: .milliseconds(50))

            do {
                let _ = try model.importWallet()
                await MainActor.run {
                    isWalletsPresented.wrappedValue = false
                }
            } catch {
                await MainActor.run {
                    isPresentingErrorMessage = error.localizedDescription
                }
            }
            await MainActor.run {
                model.buttonState = .normal
            }
        }
    }
}
