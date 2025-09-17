// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

public struct OnboardingScene: View {
    private let model: OnboardingViewModel

    public init(model: OnboardingViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 24) {
                StateButton(
                    text: model.createWalletTitle,
                    action: model.onCreateWallet
                )
                StateButton(
                    text: model.importWalletTitle,
                    action: model.onImportWallet
                )
            }
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.scene.bottom * 2)
        }
        .overlay(
            LogoView()
        )
        .frame(maxWidth: .infinity)
        .background(Colors.white)
        .navigationTitle(model.title)
    }
}
