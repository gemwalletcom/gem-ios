// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct ShowPrivateKeyScene: View {

    let model: ShowPrivateKeyModel
    @State private var showCopyMessage = false

    var body: some View {
        VStack(spacing: Spacing.medium) {
            // FIXME add localize strings
            CalloutView.error(
                title: Localized.SecretPhrase.DoNotShare.title,
                subtitle: Localized.SecretPhrase.DoNotShare.description
            )
            .padding(.top, Spacing.scene.top)
            
            // FIXME fix the UI design
            //In the future add selector to show base58/hex value

            Section(model.encoding.rawValue) {
                Text(
                    model.text
                )
                .font(.footnote)
                .padding(Spacing.scene.top)
            }

            Button {
                showCopyMessage = true
                UIPasteboard.general.string = model.text
            } label: {
                Text(Localized.Common.copy)
            }
            Spacer()
        }
        .modifier(ToastModifier(
            isPresenting: $showCopyMessage,
            value: CopyTypeViewModel(type: .privateKey).message,
            systemImage: SystemImage.copy
        ))
        .frame(maxWidth: Spacing.scene.content.maxWidth)
        .navigationTitle(model.title)
    }
}

struct ShowPrivateKeyScene_Preview: PreviewProvider {
    static var previews: some View {
        ShowPrivateKeyScene(
            model: ShowPrivateKeyModel(text: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz", encoding: .base58)
        )
    }
}
