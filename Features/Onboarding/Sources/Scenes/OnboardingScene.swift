// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components

public struct OnboardingScene: View {
    @Binding private var isPresentingCreateWalletSheet: Bool
    @Binding private var isPresentingImportWalletSheet: Bool

    private let model: OnboardingViewModel

    public init(
        model: OnboardingViewModel,
        isPresentingCreateWalletSheet: Binding<Bool>,
        isPresentingImportWalletSheet: Binding<Bool>
    ) {
        self.model = model
        _isPresentingCreateWalletSheet = isPresentingCreateWalletSheet
        _isPresentingImportWalletSheet = isPresentingImportWalletSheet
    }

    public var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center, spacing: 24) {
                Button(model.createWalletTitle) {
                    isPresentingCreateWalletSheet.toggle()
                }
                .buttonStyle(.blue())
                .accessibilityIdentifier("welcome_create")
                Button(model.importWalletTitle) {
                    isPresentingImportWalletSheet.toggle()
                }
                .buttonStyle(.blue())
                .accessibilityIdentifier("welcome_import")
            }
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .padding(Spacing.scene.bottom * 2)
        }
        .overlay(
            LogoView()
        )
        .frame(maxWidth: .infinity)
        .background(Colors.white)
        .navigationTitle(model.title)
    }
}
