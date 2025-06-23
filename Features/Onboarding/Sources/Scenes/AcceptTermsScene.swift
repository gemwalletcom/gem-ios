// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization
import Components
import Primitives

struct AcceptTermsScene: View {
    @State private var model: AcceptTermsViewModel
    
    init(model: AcceptTermsViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: .medium) {
            List {
                CalloutView(style: .header(title: model.message))
                    .cleanListRow()

                ForEach($model.items) { $item in
                    Section {
                        Toggle(isOn: $item.isConfirmed) {
                            Text(item.message)
                                .textStyle(item.style)
                        }
                        .accessibilityIdentifier(item.id)
                        .toggleStyle(CheckboxStyle(position: .left))
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))
            
            Spacer()
            
            StateButton(
                text: Localized.Onboarding.AcceptTerms.continue,
                variant: .primary(model.state),
                action: { model.onNext?() }
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbarInfoButton(url: model.termsAndServicesURL)
    }
}
