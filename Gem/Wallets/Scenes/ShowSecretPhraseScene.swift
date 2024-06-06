// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct CalloutView: View {
    
    public let title: String?
    public let titleStyle: TextStyle
    public let subtitle: String?
    public let subtitleStyle: TextStyle
    public let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: Spacing.medium) {
            if let title = title {
                Text(title)
                    .font(titleStyle.font)
                    .foregroundColor(titleStyle.color)
                    .multilineTextAlignment(.center)
            }
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(subtitleStyle.font)
                    .foregroundColor(subtitleStyle.color)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(Spacing.small)
    }
}

extension CalloutView {
    static func error(
        title: String?,
        subtitle: String?
    ) -> some View {
        return CalloutView(
            title: title,
            titleStyle: TextStyle(font: .system(.body, weight: .medium), color: Colors.red),
            subtitle: subtitle,
            subtitleStyle: TextStyle(font: .callout, color: Colors.red),
            backgroundColor: Colors.redLight
        )
    }
}

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
