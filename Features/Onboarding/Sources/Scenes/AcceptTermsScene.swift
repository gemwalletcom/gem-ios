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
                
                ForEach($model.items) { $item in
                    Section {
                        Toggle(isOn: $item.isConfirmed) {
                            Text(item.message)
                                .textStyle(.bodySecondary)
                        }
                        .toggleStyle(CheckboxStyle(position: .left))
                    }
                    .listRowInsets(.assetListRowInsets)
                }
            }
            .contentMargins([.top], .extraSmall, for: .scrollContent)
            .listSectionSpacing(.custom(.medium))
            
            Spacer()
            
            StateButton(
                text: "I Understand, Continue",
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
            }
        }
        .safariSheet(url: $isPresentingUrl)
    }
}
