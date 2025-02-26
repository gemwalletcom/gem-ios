// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents

struct ShowSecretDataScene: View {
    
    let model: any SecretPhraseViewableModel
    @State private var showCopyMessage = false

    var body: some View {
        VStack(spacing: .medium) {
            CalloutView.error(
                title: Localized.SecretPhrase.DoNotShare.title, 
                subtitle: Localized.SecretPhrase.DoNotShare.description
            )
            .padding(.top, .scene.top)

            SecretDataTypeView(type: model.type)

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
        .frame(maxWidth: .scene.content.maxWidth)
        .navigationTitle(model.title)
    }
}
