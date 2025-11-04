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
        List {
            if let calloutViewStyle = model.calloutViewStyle {
                CalloutView(style: calloutViewStyle)
                    .cleanListRow()
                    .padding(.horizontal, .medium)
            }
            
            Section {
                SecretDataTypeView(
                    type: model.type
                )
            }
            .cleanListRow()
            
            ListButton(
                title: Localized.Common.copy,
                image: Images.System.copy,
                action: copy
            )
            .frame(maxWidth: .infinity, alignment: .center)
            .cleanListRow()
        }
        .safeAreaView {
            if model.continueAction != nil {
                StateButton(
                    text: Localized.Common.continue,
                    action: continueAction
                )
                .frame(maxWidth: .scene.button.maxWidth)
                .padding(.bottom, .scene.bottom)
            }
        }
        .contentMargins([.top], .extraSmall, for: .scrollContent)
        .listSectionSpacing(.custom(.medium))
        .toolbarInfoButton(url: model.docsUrl)
        .navigationTitle(model.title)
        .copyToast(
            model: model.copyModel,
            isPresenting: $isPresentingCopyToast
        )
    }
    
    private func copy() {
        isPresentingCopyToast = true
    }
    
    func continueAction() {
        model.continueAction?()
    }
}
