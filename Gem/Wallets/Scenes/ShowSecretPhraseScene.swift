// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct ShowSecretPhraseScene: View {
    
    let model: ShowSecretPhraseViewModel
    @State private var showCopyMessage = false

    var body: some View {
        VStack(spacing: 16) {
            CalloutView.error(
                title: Localized.SecretPhrase.DoNotShare.title, 
                subtitle: Localized.SecretPhrase.DoNotShare.description
            )
            .padding(.top, Spacing.scene.top)
            
            SecretPhraseGridView(rows: model.rows)
                .padding(.top, Spacing.scene.top)
            Button {
                showCopyMessage = true
                UIPasteboard.general.string = MnemonicFormatter.fromArray(words: model.words)
            } label: {
                Text(Localized.Common.copy)
            }
            Spacer()
        }
        .modifier(ToastModifier(
            isPresenting: $showCopyMessage,
            value: CopyTypeViewModel(type: .secretPhrase).message,
            systemImage: SystemImage.copy
        ))
        .frame(maxWidth: Spacing.scene.content.maxWidth)
        .navigationTitle(model.title)
    }
}

struct ShowSecretPhraseScene_Previews: PreviewProvider {
    static var previews: some View {
        ShowSecretPhraseScene(model: ShowSecretPhraseViewModel(words: ["test"]))
    }
}
