// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization
import PrimitivesComponents

struct ShowSecretDataScene: View {
    
    let model: any SecretPhraseViewableModel
    @State private var isPresentingCopyToast = false

    var body: some View {
        VStack {
            List {
                Section {
                    CalloutView.error(
                        title: Localized.SecretPhrase.DoNotShare.title,
                        subtitle: Localized.SecretPhrase.DoNotShare.description
                    )
                }
                .cleanListRow()

                Section {
                    SecretDataTypeView(
                        type: model.type
                    )
                }
                .cleanListRow()

                Section {
                    Button {
                        isPresentingCopyToast = true
                    } label: {
                        Text(Localized.Common.copy)
                    }
                }
                .cleanListRow()
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .copyToast(
            model: model.copyModel,
            isPresenting: $isPresentingCopyToast
        )
    }
}
