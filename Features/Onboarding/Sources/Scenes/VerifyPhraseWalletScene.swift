// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import PrimitivesComponents
import Primitives

struct VerifyPhraseWalletScene: View {
    
    @State var model: VerifyPhraseViewModel
    private let router: Routing

    init(
        model: VerifyPhraseViewModel,
        router: Routing
    ) {
        _model = .init(initialValue: model)
        self.router = router
    }

    var body: some View {
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
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .navigationTitle(model.title)
    }

}

// MARK: - Actions

extension VerifyPhraseWalletScene {
    func onImportWallet() {
        model.buttonState = .loading(showProgress: true)

        Task {
            try await Task.sleep(for: .milliseconds(50))
            await MainActor.run {
                do {
                    try model.importWallet()
                    router.onFinishFlow?()
                } catch {
                    router.presentAlert(
                        title: Localized.Errors.createWallet(""),
                        message: error.localizedDescription
                    )
                    model.buttonState = .normal
                }

            }
        }
    }
}
