// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct ShowSecretDataScene: View {
    
    let model: SecretPhraseViewableModel
    @State private var showCopyMessage = false

    var body: some View {
        VStack(spacing: Spacing.medium) {
            CalloutView.error(
                title: Localized.SecretPhrase.DoNotShare.title, 
                subtitle: Localized.SecretPhrase.DoNotShare.description
            )
            .padding(.top, Spacing.scene.top)
            

            switch model.type {
            case .words(let rows):
                SecretPhraseGridView(rows: rows)
                    .padding(.top, Spacing.scene.top)
            case .privateKey(let key):
                Text(key)
                    .padding(.top, Spacing.scene.top)
            }

            Button {
                showCopyMessage = true
                UIPasteboard.general.string = model.copyValue
            } label: {
                Text(Localized.Common.copy)
            }
            Spacer()
        }
        .modifier(ToastModifier(
            isPresenting: $showCopyMessage,
            value: CopyTypeViewModel(type: model.copyType).message,
            systemImage: SystemImage.copy
        ))
        .frame(maxWidth: Spacing.scene.content.maxWidth)
        .navigationTitle(model.title)
    }
}

struct ShowSecretPhraseScene_Previews: PreviewProvider {
    static var previews: some View {
        ShowSecretDataScene(model: ShowSecretPhraseViewModel(words: ["test"]))
    }
}
