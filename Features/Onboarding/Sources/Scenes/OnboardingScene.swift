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
                Button(model.importWalletTitle) {
                    isPresentingImportWalletSheet.toggle()
                }
                .buttonStyle(.blue())
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
