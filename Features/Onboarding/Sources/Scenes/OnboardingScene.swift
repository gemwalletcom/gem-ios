// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Localization

public struct OnboardingScene: View {
    @Binding private var isPresentingCreateWalletSheet: Bool
    @Binding private var isPresentingImportWalletSheet: Bool

    public init(
        isPresentingCreateWalletSheet: Binding<Bool>,
        isPresentingImportWalletSheet: Binding<Bool>
    ) {
        _isPresentingCreateWalletSheet = isPresentingCreateWalletSheet
        _isPresentingImportWalletSheet = isPresentingImportWalletSheet
    }

    public var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 24) {
                StateButton(
                    text: Localized.Wallet.createNewWallet,
                    action: { isPresentingCreateWalletSheet = true }
                )
                StateButton(
                    text: Localized.Wallet.importExistingWallet,
                    action: { isPresentingImportWalletSheet = true }
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
        .navigationTitle(Localized.Welcome.title)
    }
}
