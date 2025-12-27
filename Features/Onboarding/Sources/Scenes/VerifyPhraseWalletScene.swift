// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import PrimitivesComponents

struct VerifyPhraseWalletScene: View {
    
    @State private var model: VerifyPhraseViewModel

    init(model: VerifyPhraseViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
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
                                    .buttonStyle(.lightGray(paddingHorizontal: .small, paddingVertical: .tiny, glassEffect: .disabled))
                                    .disabled(true)
                                    .fixedSize()
                                } else {
                                    Button {
                                        model.pickWord(index: row)
                                    } label: {
                                        Text(row.word)
                                    }
                                    .buttonStyle(.blueGrayPressed(paddingHorizontal: .small, paddingVertical: .tiny, glassEffect: .disabled))
                                    .fixedSize()
                                }
                            }
                        }
                    }
                }
            }
            .cleanListRow()
        }
        .safeAreaView {
            StateButton(
                text: Localized.Common.continue,
                type: .primary(model.buttonState),
                action: model.onContinue
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .contentMargins([.top], .extraSmall, for: .scrollContent)
        .listSectionSpacing(.custom(.medium))
        .navigationTitle(model.title)
        .alertSheet($model.isPresentingAlertMessage)
        .detectScreenshots(docsUrl: model.docsUrl)
        .protectFromScreenRecording()
    }

}

