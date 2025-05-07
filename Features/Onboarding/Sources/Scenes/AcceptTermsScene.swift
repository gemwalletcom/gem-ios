// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Localization
import Components
import Primitives
import GemstonePrimitives

struct AcceptTermsScene: View {
    @State private var model: AcceptTermsViewModel
    private let router: Routing
    private var onNext: VoidAction
    
    init(
        model: AcceptTermsViewModel,
        router: Routing,
        onNext: VoidAction
    ) {
        self.model = model
        self.router = router
        self.onNext = onNext
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
                infoTitle: "By checking the boxes, you agree to these terms.",
                action:  { onNext?() }
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
                    presentTermsOfService()
                }
            }
        }
    }
}

// MARK: - Actions

extension AcceptTermsScene {
    private func presentTermsOfService() {
        router.isPresentingUrl = PublicConstants.url(.termsOfService)
    }
}
