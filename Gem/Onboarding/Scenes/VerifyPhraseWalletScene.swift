// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct VerifyPhraseWalletScene: View {
    
    @Binding var path: NavigationPath
    @StateObject var model: VerifyPhraseViewModel

    @Environment(\.isWalletsPresented) private var isWalletsPresented
    
    @State private var isPresentingErrorMessage: String?
    @State private var isLoading: Bool = false
    
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
                Button(Localized.Common.continue, action: importWallet)
                    .disabled(model.isContinueDisabled)
                    .buttonStyle(.blue())
                    .frame(maxWidth: Spacing.scene.button.maxWidth)
            }
            .frame(maxWidth: Spacing.scene.content.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .navigationTitle(model.title)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.createWallet("")), message: Text($0))
        }
        .modifier(
            ActivityIndicatorModifier(message: Localized.Common.loading, isLoading: isLoading)
        )
    }
    
    func importWallet() {
        isLoading = true
        do {
            let _ = try model.importWallet()
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
        isLoading = false

        isWalletsPresented.wrappedValue = false
    }
}
