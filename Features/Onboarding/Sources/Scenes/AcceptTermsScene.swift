// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization
import Components
import Primitives

struct AcceptTermsScene: View {
    @State private var isPresentingUrl: URL? = nil
    @State private var model: AcceptTermsViewModel
    
    init(model: AcceptTermsViewModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: .medium) {
            List {
                OnboardingHeaderTitle(title: model.message, alignment: .center)
                    .cleanListRow()
                
                ForEach(Array($model.items.enumerated()), id: \.element.id) { index, $item in
                    Section {
                        Toggle(isOn: $item.isConfirmed) {
                            Text(item.message)
                                .textStyle(item.style)
                        }
                        .accessibilityIdentifier(AccessibilityIdentifier.Onboarding.acceptTermsToggle(index).id)
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
                viewState: model.buttonState,
                action: { model.onNext?() }
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: SystemImage.info) {
                    isPresentingUrl = model.termsAndServicesURL
                }
                .accessibilityIdentifier(AccessibilityIdentifier.Common.safariInfoButton.id)
            }
        }
        .safariSheet(url: $isPresentingUrl)
    }
}
